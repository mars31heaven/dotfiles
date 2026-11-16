#!/usr/bin/env bash

# Select music folders in Neovim, then convert FLAC/WAV files in the retained
# folders to Opus.
#
# Usage:
#   ./nvim-select-opus-convert.sh
#   ./nvim-select-opus-convert.sh ~/Music
#
# Workflow:
#   1. A folder list opens in Neovim.
#   2. Keep the folder lines you want to convert.
#   3. Delete the folder lines you want to remain FLAC/WAV.
#   4. Save and quit with :wq.
#   5. Confirm conversion with y.
#
# Safety:
#   - Originals are retained by default.
#   - Existing .opus files are never overwritten.
#   - Incomplete conversions use a .tmp.opus file.
#   - The script cancels if you quit Neovim without saving a changed list.

set -u
set -o pipefail

BITRATE="192k"

# Keep originals by default.
#
# Change this to 1 only after you have tested the resulting Opus files and
# confirmed that you no longer need the FLAC/WAV originals.
DELETE_ORIGINALS=1

ROOT_DIRECTORY="${1:-.}"

if ! command -v nvim >/dev/null 2>&1; then
    printf 'Error: Neovim is not installed or not available in PATH.\n' >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    printf 'Error: ffmpeg is not installed or not available in PATH.\n' >&2
    exit 1
fi

if ! ROOT_DIRECTORY="$(realpath -- "$ROOT_DIRECTORY")"; then
    printf 'Error: could not resolve directory: %s\n' "${1:-.}" >&2
    exit 1
fi

if [[ ! -d "$ROOT_DIRECTORY" ]]; then
    printf 'Error: not a directory: %s\n' "$ROOT_DIRECTORY" >&2
    exit 1
fi

FOLDER_LIST="$(mktemp --tmpdir opus-folders.XXXXXX.txt)"
ORIGINAL_FOLDER_LIST="${FOLDER_LIST}.original"

cleanup() {
    rm -f -- "$FOLDER_LIST" "$ORIGINAL_FOLDER_LIST"
}

trap cleanup EXIT

printf 'Searching for directories containing FLAC or WAV files...\n'

# Build a unique list of directories containing at least one FLAC or WAV file.
find "$ROOT_DIRECTORY" \
    -type f \
    \( -iname '*.flac' -o -iname '*.wav' \) \
    -printf '%h\n' |
    sort -u > "$FOLDER_LIST"

if [[ ! -s "$FOLDER_LIST" ]]; then
    printf 'No FLAC or WAV files were found under:\n%s\n' "$ROOT_DIRECTORY"
    exit 0
fi

FOLDER_COUNT="$(wc -l < "$FOLDER_LIST")"

# Add readable instructions at the start of the Neovim buffer.
{
    printf '# ┌────────────────────────────────────────────────────────────────────────────┐\n'
    printf '# │ Opus conversion folder selection                                         │\n'
    printf '# └────────────────────────────────────────────────────────────────────────────┘\n'
    printf '#\n'
    printf '# Keep a folder line to convert its FLAC/WAV files to Opus at %s.\n' "$BITRATE"
    printf '# Delete a folder line to keep that folder in lossless FLAC/WAV format.\n'
    printf '#\n'
    printf '# Commands:\n'
    printf '#   :wq  Save selected folders and continue to confirmation.\n'
    printf '#   :q   Quit without changes and cancel conversion.\n'
    printf '#   :q!  Quit without saving and cancel conversion.\n'
    printf '#\n'
    printf '# Lines beginning with # and empty lines are ignored.\n'
    printf '# ────────────────────────────────────────────────────────────────────────────\n'
    cat "$FOLDER_LIST"
} > "${FOLDER_LIST}.edit"

mv -- "${FOLDER_LIST}.edit" "$FOLDER_LIST"

# Preserve the unedited version. If it remains identical after Neovim closes,
# no conversion will occur.
cp -- "$FOLDER_LIST" "$ORIGINAL_FOLDER_LIST"

printf '\nFound %s directory/directories containing FLAC or WAV files.\n' "$FOLDER_COUNT"
printf 'Opening selection list in Neovim...\n\n'

# Visual improvements:
# - Line numbers
# - Current-line highlight
# - No wrapping of long folder paths
# - Comment lines use your Neovim Comment highlight group
# - Folder paths use the Directory highlight group
nvim \
    -c 'setlocal number relativenumber cursorline nowrap' \
    -c 'syntax clear' \
    -c 'syntax match OpusSelectionComment /^#.*/' \
    -c 'highlight default link OpusSelectionComment Comment' \
    -c 'call matchadd("Directory", "^[^#[:space:]].*$")' \
    "$FOLDER_LIST"

NVIM_STATUS=$?

if [[ $NVIM_STATUS -ne 0 ]]; then
    printf 'Neovim exited with status %s. No conversion started.\n' \
        "$NVIM_STATUS" >&2
    exit 1
fi

# If the file was not changed and saved, cancel.
#
# This covers:
#   :q
#   :q!
#   Opening Neovim, making no changes, then using :wq
if cmp -s -- "$FOLDER_LIST" "$ORIGINAL_FOLDER_LIST"; then
    printf '\nNo changed folder selection was saved. Conversion cancelled.\n'
    printf 'To convert folders, delete unwanted folder lines and use :wq.\n'
    exit 0
fi

# Count the selected folder lines after editing.
SELECTED_FOLDERS="$(
    grep -cvE '^[[:space:]]*(#|$)' "$FOLDER_LIST" || true
)"

if [[ "$SELECTED_FOLDERS" -eq 0 ]]; then
    printf '\nNo folders remain selected. Conversion cancelled.\n'
    exit 0
fi

printf '\nSelected folders for conversion: %s\n' "$SELECTED_FOLDERS"
printf 'Opus bitrate: %s\n' "$BITRATE"

if [[ "$DELETE_ORIGINALS" -eq 1 ]]; then
    printf 'Original FLAC/WAV files: WILL BE DELETED after successful conversion.\n'
else
    printf 'Original FLAC/WAV files: will be retained.\n'
fi

printf '\nProceed with conversion? [y/N] '

read -r confirmation

case "$confirmation" in
    y|Y|yes|YES|Yes)
        ;;
    *)
        printf 'Conversion cancelled.\n'
        exit 0
        ;;
esac

convert_file() {
    local input="$1"
    local output
    local temporary

    output="${input%.*}.opus"
    temporary="${input%.*}.tmp.opus"

    # Do not overwrite existing conversions.
    if [[ -e "$output" ]]; then
        printf 'SKIP: Opus file already exists:\n  %s\n' "$output"
        return 2
    fi

    # Avoid touching a previous incomplete conversion without review.
    if [[ -e "$temporary" ]]; then
        printf 'SKIP: temporary output already exists:\n  %s\n' "$temporary"
        return 2
    fi

    printf 'CONVERTING:\n  %s\n' "$input"

    if ffmpeg \
        -hide_banner \
        -nostdin \
        -i "$input" \
        -map 0:a:0 \
        -map_metadata 0 \
        -c:a libopus \
        -b:a "$BITRATE" \
        -vbr on \
        "$temporary"; then

        mv -- "$temporary" "$output"

        printf 'DONE:\n  %s\n' "$output"

        if [[ "$DELETE_ORIGINALS" -eq 1 ]]; then
            rm -- "$input"
            printf 'REMOVED ORIGINAL:\n  %s\n' "$input"
        fi

        return 0
    fi

    printf 'FAILED:\n  %s\n' "$input" >&2
    rm -f -- "$temporary"
    return 1
}

processed_folders=0
converted_files=0
skipped_files=0
failed_files=0

printf '\nStarting conversion...\n\n'

while IFS= read -r folder || [[ -n "$folder" ]]; do
    # Ignore headings, comments, and empty lines.
    [[ -z "$folder" ]] && continue
    [[ "$folder" == \#* ]] && continue

    if [[ ! -d "$folder" ]]; then
        printf 'WARNING: folder no longer exists, skipping:\n  %s\n' \
            "$folder" >&2
        continue
    fi

    printf '\n%s\n' \
        '================================================================================'
    printf 'FOLDER:\n  %s\n' "$folder"
    printf '%s\n' \
        '================================================================================'

    folder_has_audio=0

    while IFS= read -r -d '' audio_file; do
        folder_has_audio=1

        if convert_file "$audio_file"; then
            converted_files=$((converted_files + 1))
        else
            status=$?

            if [[ $status -eq 2 ]]; then
                skipped_files=$((skipped_files + 1))
            else
                failed_files=$((failed_files + 1))
            fi
        fi
    done < <(
        find "$folder" \
            -maxdepth 1 \
            -type f \
            \( -iname '*.flac' -o -iname '*.wav' \) \
            -print0
    )

    if [[ "$folder_has_audio" -eq 1 ]]; then
        processed_folders=$((processed_folders + 1))
    fi
done < "$FOLDER_LIST"

printf '\n%s\n' \
    '================================================================================'
printf 'CONVERSION SUMMARY\n'
printf '%s\n' \
    '================================================================================'
printf 'Folders processed: %s\n' "$processed_folders"
printf 'Files converted: %s\n' "$converted_files"
printf 'Files skipped because .opus already exists: %s\n' "$skipped_files"
printf 'Files that failed: %s\n' "$failed_files"

if [[ "$DELETE_ORIGINALS" -eq 1 ]]; then
    printf 'Original FLAC/WAV files: removed after successful conversion\n'
else
    printf 'Original FLAC/WAV files: retained\n'
fi
