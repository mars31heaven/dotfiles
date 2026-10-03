#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import os
import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from itertools import combinations
from pathlib import Path
from typing import Iterable

try:
    from PIL import Image, UnidentifiedImageError
except ImportError:
    print(
        "Error: Pillow is not installed.\n\n"
        "Install it with:\n"
        "  python -m pip install --user Pillow",
        file=sys.stderr,
    )
    raise SystemExit(1)


# Common camera and image formats.
#
# RAW formats are not included because Pillow cannot reliably read all of them.
# You can add more extensions if needed.
IMAGE_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".jpe",
    ".png",
    ".webp",
    ".tif",
    ".tiff",
    ".heic",
    ".heif",
    ".bmp",
    ".gif",
}


@dataclass
class PhotoInfo:
    """Information gathered for a confirmed duplicate image."""

    path: Path
    size: int
    sha256: str
    capture_date: str | None
    dimensions: str | None
    camera: str | None
    normalized_name: str


def format_size(size_bytes: int) -> str:
    """Format a byte count in a readable unit."""
    units = ("B", "KiB", "MiB", "GiB", "TiB")
    value = float(size_bytes)

    for unit in units:
        if value < 1024 or unit == units[-1]:
            return f"{value:.1f} {unit}"
        value /= 1024

    return f"{size_bytes} B"


def hash_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    """
    Return the SHA-256 hash of a file.

    The file is read in chunks, so large image files do not need to be loaded
    entirely into memory.
    """
    digest = hashlib.sha256()

    with path.open("rb") as file:
        while chunk := file.read(chunk_size):
            digest.update(chunk)

    return digest.hexdigest()


def normalize_filename(name: str) -> str:
    """
    Create a simplified filename for informational comparison.

    Examples:
        IMG_0001.JPG       -> img0001
        IMG-0001 (1).jpg   -> img0001
        Lisbon photo.jpg   -> lisbonphoto
    """
    stem = Path(name).stem.lower()

    # Remove common duplicate suffixes such as "(1)" or "(2)".
    stem = re.sub(r"\s*\(\d+\)$", "", stem)

    # Keep only letters and numbers for a loose comparison.
    return re.sub(r"[^a-z0-9]+", "", stem)


def clean_exif_value(value: object) -> str | None:
    """Convert EXIF data to clean text."""
    if value is None:
        return None

    text = str(value).strip()
    return text or None


def get_photo_metadata(path: Path) -> tuple[str | None, str | None, str | None]:
    """
    Read available photo metadata.

    Returns:
        capture_date, dimensions, camera

    Metadata is shown only as context. Exact duplicate confirmation always
    depends on file size and SHA-256 hash.
    """
    try:
        with Image.open(path) as image:
            dimensions = f"{image.width}×{image.height}"
            exif = image.getexif()

            # Standard EXIF date fields:
            # 36867 = DateTimeOriginal
            # 36868 = DateTimeDigitized
            # 306   = DateTime
            raw_date = (
                exif.get(36867)
                or exif.get(36868)
                or exif.get(306)
            )

            capture_date = None

            if raw_date:
                raw_date_text = clean_exif_value(raw_date)

                if raw_date_text:
                    try:
                        parsed_date = datetime.strptime(
                            raw_date_text,
                            "%Y:%m:%d %H:%M:%S",
                        )
                        capture_date = parsed_date.strftime("%Y-%m-%d %H:%M:%S")
                    except ValueError:
                        capture_date = raw_date_text

            # EXIF 271 = Make; EXIF 272 = Model
            make = clean_exif_value(exif.get(271))
            model = clean_exif_value(exif.get(272))

            camera_parts = [part for part in (make, model) if part]
            camera = " ".join(camera_parts) if camera_parts else None

            return capture_date, dimensions, camera

    except (UnidentifiedImageError, OSError, ValueError):
        return None, None, None


def find_image_files(root: Path) -> Iterable[Path]:
    """
    Yield image files under root recursively.

    Hidden directories are skipped. Remove the directories[:] block below if
    you also want to scan hidden folders such as .cache or .local.
    """
    for current_root, directories, filenames in os.walk(
        root,
        followlinks=False,
    ):
        # Avoid hidden folders and their contents.
        directories[:] = [
            directory
            for directory in directories
            if not directory.startswith(".")
        ]

        current_path = Path(current_root)

        for filename in filenames:
            path = current_path / filename

            if path.suffix.lower() in IMAGE_EXTENSIONS:
                yield path


def find_duplicate_groups(root: Path) -> list[list[PhotoInfo]]:
    """
    Find confirmed exact duplicate image groups.

    Process:
      1. Group image files by size.
      2. Hash only files whose size appears more than once.
      3. Group files with identical SHA-256 hashes.
      4. Read metadata only for confirmed duplicate files.
    """
    files_by_size: dict[int, list[Path]] = defaultdict(list)

    print("Scanning image files...")

    image_count = 0
    unreadable_count = 0

    for path in find_image_files(root):
        try:
            files_by_size[path.stat().st_size].append(path)
            image_count += 1
        except OSError as error:
            unreadable_count += 1
            print(f"Warning: could not read {path}: {error}", file=sys.stderr)

    possible_duplicate_groups = [
        paths
        for paths in files_by_size.values()
        if len(paths) > 1
    ]

    possible_file_count = sum(
        len(paths)
        for paths in possible_duplicate_groups
    )

    print(f"Images scanned: {image_count}")
    print(f"Files with a repeated size: {possible_file_count}")

    if unreadable_count:
        print(f"Unreadable files skipped: {unreadable_count}")

    print("Calculating hashes for possible duplicates...")
    print()

    files_by_hash: dict[str, list[Path]] = defaultdict(list)

    for paths in possible_duplicate_groups:
        for path in paths:
            try:
                sha256 = hash_file(path)
                files_by_hash[sha256].append(path)
            except OSError as error:
                print(
                    f"Warning: could not hash {path}: {error}",
                    file=sys.stderr,
                )

    duplicate_groups: list[list[PhotoInfo]] = []

    for sha256, paths in files_by_hash.items():
        if len(paths) < 2:
            continue

        group: list[PhotoInfo] = []

        for path in sorted(paths, key=lambda item: str(item).lower()):
            try:
                file_size = path.stat().st_size
            except OSError:
                continue

            capture_date, dimensions, camera = get_photo_metadata(path)

            group.append(
                PhotoInfo(
                    path=path,
                    size=file_size,
                    sha256=sha256,
                    capture_date=capture_date,
                    dimensions=dimensions,
                    camera=camera,
                    normalized_name=normalize_filename(path.name),
                )
            )

        if len(group) > 1:
            duplicate_groups.append(group)

    return sorted(
        duplicate_groups,
        key=lambda group: (
            group[0].capture_date or "9999-99-99",
            str(group[0].path).lower(),
        ),
    )


def summarize_duplicates_by_folder(
    duplicate_groups: list[list[PhotoInfo]],
) -> list[dict[str, object]]:
    """
    Summarize duplicate relationships between folder pairs.

    A duplicate group found in Folder A and Folder B contributes one shared
    duplicate set to the relationship between those folders.

    If the same image exists in three folders, it contributes to all relevant
    pairs: A/B, A/C and B/C.
    """
    relationships: dict[tuple[Path, Path], dict[str, int]] = defaultdict(
        lambda: {
            "duplicate_groups": 0,
            "files_involved": 0,
            "estimated_duplicate_bytes": 0,
            "same_name_groups": 0,
            "different_name_groups": 0,
        }
    )

    for group in duplicate_groups:
        copies_by_folder: dict[Path, list[PhotoInfo]] = defaultdict(list)

        for item in group:
            copies_by_folder[item.path.parent].append(item)

        folders = sorted(
            copies_by_folder.keys(),
            key=lambda path: str(path).lower(),
        )

        # Duplicates entirely inside the same folder do not create a
        # relationship between different folders.
        if len(folders) < 2:
            continue

        file_size = group[0].size
        normalized_names = {item.normalized_name for item in group}

        for folder_a, folder_b in combinations(folders, 2):
            copies_a = copies_by_folder[folder_a]
            copies_b = copies_by_folder[folder_b]

            relationship = relationships[(folder_a, folder_b)]

            relationship["duplicate_groups"] += 1
            relationship["files_involved"] += len(copies_a) + len(copies_b)

            # Conservative estimate: count only the number of copies both
            # folders have in common for this exact image.
            relationship["estimated_duplicate_bytes"] += (
                min(len(copies_a), len(copies_b)) * file_size
            )

            if len(normalized_names) == 1:
                relationship["same_name_groups"] += 1
            else:
                relationship["different_name_groups"] += 1

    summary: list[dict[str, object]] = []

    for (folder_a, folder_b), data in relationships.items():
        summary.append(
            {
                "folder_a": folder_a,
                "folder_b": folder_b,
                "duplicate_groups": data["duplicate_groups"],
                "files_involved": data["files_involved"],
                "estimated_duplicate_bytes": data[
                    "estimated_duplicate_bytes"
                ],
                "same_name_groups": data["same_name_groups"],
                "different_name_groups": data["different_name_groups"],
            }
        )

    return sorted(
        summary,
        key=lambda item: (
            int(item["duplicate_groups"]),
            int(item["estimated_duplicate_bytes"]),
        ),
        reverse=True,
    )


def summarize_duplicates_inside_folders(
    duplicate_groups: list[list[PhotoInfo]],
) -> list[dict[str, object]]:
    """
    Summarize duplicate copies that exist within the same folder.

    This is useful when a folder contains files such as:
      IMG_0001.JPG
      IMG_0001 (1).JPG
    """
    folder_summary: dict[Path, dict[str, int]] = defaultdict(
        lambda: {
            "duplicate_groups": 0,
            "extra_copies": 0,
            "recoverable_bytes": 0,
        }
    )

    for group in duplicate_groups:
        copies_by_folder: dict[Path, list[PhotoInfo]] = defaultdict(list)

        for item in group:
            copies_by_folder[item.path.parent].append(item)

        for folder, copies in copies_by_folder.items():
            if len(copies) < 2:
                continue

            extra_copies = len(copies) - 1
            data = folder_summary[folder]

            data["duplicate_groups"] += 1
            data["extra_copies"] += extra_copies
            data["recoverable_bytes"] += extra_copies * group[0].size

    summary: list[dict[str, object]] = []

    for folder, data in folder_summary.items():
        summary.append(
            {
                "folder": folder,
                "duplicate_groups": data["duplicate_groups"],
                "extra_copies": data["extra_copies"],
                "recoverable_bytes": data["recoverable_bytes"],
            }
        )

    return sorted(
        summary,
        key=lambda item: (
            int(item["recoverable_bytes"]),
            int(item["duplicate_groups"]),
        ),
        reverse=True,
    )


def build_report(root: Path, duplicate_groups: list[list[PhotoInfo]]) -> str:
    """
    Build a compact folder-oriented duplicate report.

    Individual files are intentionally not listed.
    """
    separator = "=" * 88

    lines = [
        separator,
        "PHOTO DUPLICATE REPORT — FOLDER SUMMARY",
        separator,
        f"Directory scanned: {root}",
        f"Confirmed exact duplicate groups: {len(duplicate_groups)}",
        "",
        (
            "Confirmation method: same file size and same SHA-256 hash. "
            "Files within a duplicate group are byte-for-byte identical."
        ),
        "",
    ]

    if not duplicate_groups:
        lines.extend(
            [
                "No exact duplicate image files were found.",
                separator,
            ]
        )
        return "\n".join(lines)

    total_files = sum(len(group) for group in duplicate_groups)
    extra_copies = sum(len(group) - 1 for group in duplicate_groups)
    recoverable_bytes = sum(
        (len(group) - 1) * group[0].size
        for group in duplicate_groups
    )

    folder_relationships = summarize_duplicates_by_folder(duplicate_groups)
    internal_folder_duplicates = summarize_duplicates_inside_folders(
        duplicate_groups
    )

    lines.extend(
        [
            f"Files involved in duplicate groups: {total_files}",
            f"Potential extra copies: {extra_copies}",
            f"Potential recoverable space: {format_size(recoverable_bytes)}",
            f"Folder-to-folder relationships: {len(folder_relationships)}",
            "",
        ]
    )

    # -------------------------------------------------------------------------
    # Duplicate relationships between distinct folders
    # -------------------------------------------------------------------------

    lines.extend(
        [
            separator,
            "1. DUPLICATES SHARED BETWEEN FOLDERS",
            separator,
            (
                "Start with the first relationships below. They identify "
                "folders that overlap the most."
            ),
            "",
        ]
    )

    if not folder_relationships:
        lines.extend(
            [
                (
                    "No duplicate groups were shared between different folders. "
                    "The duplicates found are contained within individual folders."
                ),
                "",
            ]
        )
    else:
        for number, relationship in enumerate(folder_relationships, start=1):
            folder_a = relationship["folder_a"]
            folder_b = relationship["folder_b"]
            duplicate_count = int(relationship["duplicate_groups"])
            files_involved = int(relationship["files_involved"])
            duplicate_bytes = int(relationship["estimated_duplicate_bytes"])
            same_name_groups = int(relationship["same_name_groups"])
            different_name_groups = int(
                relationship["different_name_groups"]
            )

            lines.extend(
                [
                    f"RELATIONSHIP {number}",
                    f"  Folder A: {folder_a}",
                    f"  Folder B: {folder_b}",
                    f"  Shared exact-photo groups: {duplicate_count}",
                    f"  File copies involved: {files_involved}",
                    (
                        "  Estimated repeated data between folders: "
                        f"{format_size(duplicate_bytes)}"
                    ),
                    (
                        "  Filename comparison: "
                        f"{same_name_groups} similar-name group(s), "
                        f"{different_name_groups} different-name group(s)"
                    ),
                    "",
                ]
            )

    # -------------------------------------------------------------------------
    # Duplicates contained inside the same folder
    # -------------------------------------------------------------------------

    lines.extend(
        [
            separator,
            "2. DUPLICATES INSIDE THE SAME FOLDER",
            separator,
            (
                "These are folders containing more than one copy of at least "
                "one exact image."
            ),
            "",
        ]
    )

    if not internal_folder_duplicates:
        lines.extend(
            [
                "No duplicate copies were found inside individual folders.",
                "",
            ]
        )
    else:
        for number, item in enumerate(internal_folder_duplicates, start=1):
            folder = item["folder"]
            duplicate_count = int(item["duplicate_groups"])
            folder_extra_copies = int(item["extra_copies"])
            folder_recoverable_bytes = int(item["recoverable_bytes"])

            lines.extend(
                [
                    f"FOLDER {number}",
                    f"  Location: {folder}",
                    f"  Duplicate image groups: {duplicate_count}",
                    f"  Extra copies in this folder: {folder_extra_copies}",
                    (
                        "  Potential recoverable space in this folder: "
                        f"{format_size(folder_recoverable_bytes)}"
                    ),
                    "",
                ]
            )

    lines.extend(
        [
            separator,
            "NOTES",
            separator,
            (
                "This report does not delete, rename, move, or modify files. "
                "Review the folder structure before removing any copies."
            ),
            (
                "The repeated-data value in folder relationships is an estimate "
                "for prioritizing review. A photo stored in three or more "
                "folders may appear in more than one relationship."
            ),
            (
                "This tool finds exact duplicates only. It does not identify "
                "the same photo when it was edited, resized, converted, "
                "compressed, or exported in a different format."
            ),
            separator,
        ]
    )

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Find exact duplicate photos recursively and summarize results "
            "by folder relationships."
        )
    )

    parser.add_argument(
        "folder",
        nargs="?",
        default=".",
        help=(
            "Main folder to scan recursively. "
            "Defaults to the current directory."
        ),
    )

    parser.add_argument(
        "--report",
        type=Path,
        help=(
            "Also save the report to a text file. "
            "Example: --report ~/photo-duplicates.txt"
        ),
    )

    args = parser.parse_args()

    root = Path(args.folder).expanduser().resolve()

    if not root.exists():
        print(f"Error: folder not found: {root}", file=sys.stderr)
        raise SystemExit(1)

    if not root.is_dir():
        print(f"Error: path is not a folder: {root}", file=sys.stderr)
        raise SystemExit(1)

    duplicate_groups = find_duplicate_groups(root)
    report = build_report(root, duplicate_groups)

    print()
    print(report)

    if args.report:
        report_path = args.report.expanduser().resolve()

        try:
            report_path.write_text(report + "\n", encoding="utf-8")
        except OSError as error:
            print(
                f"Error: could not write report to {report_path}: {error}",
                file=sys.stderr,
            )
            raise SystemExit(1)

        print()
        print(f"Report saved to: {report_path}")


if __name__ == "__main__":
    main()
