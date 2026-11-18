#!/usr/bin/env python3
"""
cybershot_variations.py

Create digital-camera image variations for older compact-camera JPEGs.

Variations:

    fixed
        Conservative correction for dark images.

    bw-digital
        Grainy, contrast-heavy, low-fi digital black and white.

    blownout
        Bright, saturated, clipped highlights with a soft bloom.
        Full resolution, no pixelation.

Usage:

    # Process JPG/JPEG files in the current directory.
    cybershot_variations.py

    # Process a specific folder.
    cybershot_variations.py "/path/to/photos"

    # Process one image.
    cybershot_variations.py DSC00235.jpg

    # Process all nested folders.
    cybershot_variations.py "/path/to/photos" --recursive

    # Create only selected variations.
    cybershot_variations.py . --only bw-digital blownout

    # Replace existing output files.
    cybershot_variations.py . --overwrite

Output structure:

    source-folder/
        DSC00235.jpg
        edited/
            fixed/DSC00235_fixed.jpg
            bw-digital/DSC00235_bw_digital.jpg
            blownout/DSC00235_blownout.jpg

Requirements:

    Python 3
    Pillow

Arch Linux installation:

    sudo pacman -S python-pillow
"""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path
from typing import Callable, Iterable

from PIL import Image, ImageChops, ImageEnhance, ImageFilter, ImageOps, ImageStat


SUPPORTED_SUFFIXES = {".jpg", ".jpeg"}
OUTPUT_FOLDER = "edited"

VARIATIONS = (
    "fixed",
    "bw-digital",
    "blownout",
)


def fail(message: str) -> None:
    """Print an error message and stop."""
    print(f"cybershot_variations: {message}", file=sys.stderr)
    raise SystemExit(1)


def image_luminance(image: Image.Image) -> Image.Image:
    """Return an 8-bit luminance image."""
    return image.convert("L")


def mean_luminance(image: Image.Image) -> float:
    """Return average luminance on a 0-255 scale."""
    return float(ImageStat.Stat(image_luminance(image)).mean[0])


def percentile_luminance(image: Image.Image, percentile: float) -> int:
    """Estimate a luminance percentile from the image histogram."""
    histogram = image_luminance(image).histogram()
    pixel_count = sum(histogram)

    if pixel_count == 0:
        return 0

    target = pixel_count * (percentile / 100.0)
    total = 0

    for value, count in enumerate(histogram):
        total += count

        if total >= target:
            return value

    return 255


def apply_gamma(image: Image.Image, gamma: float) -> Image.Image:
    """
    Apply gamma correction.

    Gamma below 1.0 brightens shadows and midtones.
    Gamma above 1.0 darkens shadows and midtones.
    """
    gamma = max(0.01, gamma)

    lookup = [
        int(round(255 * ((value / 255) ** gamma)))
        for value in range(256)
    ]

    if image.mode == "L":
        return image.point(lookup)

    return image.convert("RGB").point(lookup * 3)


def pixelate(image: Image.Image, pixel_size: int) -> Image.Image:
    """Create restrained digital pixel structure."""
    if pixel_size <= 1:
        return image.copy()

    width, height = image.size

    reduced_width = max(1, width // pixel_size)
    reduced_height = max(1, height // pixel_size)

    reduced = image.resize(
        (reduced_width, reduced_height),
        Image.Resampling.BOX,
    )

    return reduced.resize(
        (width, height),
        Image.Resampling.NEAREST,
    )


def add_monochrome_noise(
    image: Image.Image,
    strength: float,
) -> Image.Image:
    """
    Add neutral digital noise.

    The same noise is applied to red, green, and blue channels, producing
    grayscale digital roughness rather than coloured speckles.
    """
    if strength <= 0:
        return image.convert("RGB")

    noise = Image.effect_noise(image.size, strength).convert("L")

    red, green, blue = image.convert("RGB").split()

    red = ImageChops.add(red, noise, scale=1.0, offset=-128)
    green = ImageChops.add(green, noise, scale=1.0, offset=-128)
    blue = ImageChops.add(blue, noise, scale=1.0, offset=-128)

    return Image.merge("RGB", (red, green, blue))


def preserve_metadata(opened_image: Image.Image) -> dict[str, bytes]:
    """Preserve EXIF metadata where Pillow exposes it."""
    exif_data = opened_image.info.get("exif")

    if exif_data:
        return {"exif": exif_data}

    return {}


def save_jpeg(
    image: Image.Image,
    output_path: Path,
    metadata: dict[str, bytes],
) -> None:
    """Save a JPEG output with visible but controlled JPEG character."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    image.convert("RGB").save(
        output_path,
        "JPEG",
        quality=92,
        subsampling=2,
        optimize=True,
        **metadata,
    )


def fixed_variation(source: Image.Image) -> Image.Image:
    """
    Conservative correction for dark compact-camera JPEGs.

    This preserves original colour relationships and avoids HDR, denoising,
    artificial sharpness, or strong colour grading.
    """
    image = source.convert("RGB")

    average = mean_luminance(image)
    midpoint = percentile_luminance(image, 50)
    highlight = percentile_luminance(image, 95)

    if average < 45 or midpoint < 40:
        gamma = 0.55
        contrast = 1.05
        colour = 1.08
        cutoff = 0.20

    elif average < 80 or midpoint < 75:
        gamma = 0.70
        contrast = 1.06
        colour = 1.06
        cutoff = 0.30

    elif average < 110:
        gamma = 0.84
        contrast = 1.04
        colour = 1.04
        cutoff = 0.45

    else:
        gamma = 0.94
        contrast = 1.02
        colour = 1.02
        cutoff = 0.60

    if highlight >= 248:
        cutoff = max(cutoff, 0.80)
        contrast = min(contrast, 1.03)

    result = apply_gamma(image, gamma)

    result = ImageOps.autocontrast(
        result,
        cutoff=cutoff,
        preserve_tone=True,
    )

    result = ImageEnhance.Contrast(result).enhance(contrast)
    result = ImageEnhance.Color(result).enhance(colour)

    return result


def bw_digital_variation(source: Image.Image) -> Image.Image:
    """
    Create a rough, grainy, deliberately digital black-and-white variation.

    This avoids analog-film traits such as sepia, film grain, soft vignettes,
    simulated scratches, or smooth monochrome rendering.
    """
    grayscale = ImageOps.grayscale(source)
    average = mean_luminance(source)

    if average < 75:
        grayscale = apply_gamma(
            grayscale.convert("RGB"),
            0.70,
        ).convert("L")

    grayscale = ImageOps.autocontrast(
        grayscale,
        cutoff=0.40,
        preserve_tone=True,
    )

    grayscale = ImageEnhance.Contrast(grayscale).enhance(1.38)

    # Five-bit tonal resolution: 32 distinct tonal levels.
    grayscale = ImageOps.posterize(grayscale, 5)

    # Restrained compact-camera digital block structure.
    grayscale = pixelate(grayscale, pixel_size=2)

    result = grayscale.convert("RGB")

    # Visible monochrome sensor/JPEG-like roughness.
    result = add_monochrome_noise(result, strength=18)

    return ImageEnhance.Contrast(result).enhance(1.10)


def shoulder_lookup(gain: float, knee: float = 0.85) -> list[int]:
    """
    Build a lookup table that multiplies by gain, then rolls highlights
    off above the knee so they flatten toward white instead of clipping
    in a harsh, ugly way.
    """
    table = []

    for value in range(256):
        x = (value / 255) * gain

        if x > knee:
            room = 1.0 - knee
            x = knee + room * (1.0 - math.exp(-(x - knee) / (room * 0.6)))

        table.append(max(0, min(255, int(round(x * 255)))))

    return table


def blownout_variation(source: Image.Image) -> Image.Image:
    """
    Bright, saturated, overexposed look at full resolution.

    Steps: lift the image, boost colour, apply a different highlight gain
    per channel (so highlights drift warm), then add a soft bloom made from
    the brightest areas. No pixelation, posterizing, or JPEG damage.
    """
    image = source.convert("RGB")
    average = mean_luminance(image)

    if average < 60:
        gamma = 0.50
    elif average < 100:
        gamma = 0.64
    else:
        gamma = 0.78

    image = apply_gamma(image, gamma)
    image = ImageEnhance.Color(image).enhance(1.25)

    # Per-channel exposure: red clips first, blue last, giving warm highlights.
    red, green, blue = image.split()
    red = red.point(shoulder_lookup(1.65))
    green = green.point(shoulder_lookup(1.50))
    blue = blue.point(shoulder_lookup(1.32))
    result = Image.merge("RGB", (red, green, blue))

    # Soft bloom from the brightest areas only.
    luma = result.convert("L")
    mask = luma.point(lambda v: max(0, min(255, (v - 150) * 2)))
    bright = ImageChops.multiply(result, mask.convert("RGB"))

    radius = max(4.0, result.width / 80)
    glow = bright.filter(ImageFilter.GaussianBlur(radius))
    glow = ImageEnhance.Brightness(glow).enhance(0.65)

    result = ImageChops.screen(result, glow)

    return ImageEnhance.Contrast(result).enhance(1.06)


def variation_filename(input_path: Path, variation: str) -> str:
    """Return the filename for an output variation."""
    safe_variation = variation.replace("-", "_")

    return f"{input_path.stem}_{safe_variation}.jpg"


def output_path_for(input_path: Path, variation: str) -> Path:
    """Place each variation in a separate folder."""
    return (
        input_path.parent
        / OUTPUT_FOLDER
        / variation
        / variation_filename(input_path, variation)
    )


def is_supported_image(path: Path, root: Path) -> bool:
    """
    Return true for a supported input JPEG outside output folders.

    Only folders below the chosen root are checked, so a root path that
    happens to contain "edited" is still processed.
    """
    if not path.is_file() or path.suffix.lower() not in SUPPORTED_SUFFIXES:
        return False

    try:
        relative_parts = path.relative_to(root).parts[:-1]
    except ValueError:
        relative_parts = ()

    return OUTPUT_FOLDER not in relative_parts


def find_images(
    target: Path,
    recursive: bool,
) -> Iterable[Path]:
    """
    Find input JPEGs.

    Any path inside a folder called "edited" below the target is ignored so
    generated outputs are never processed as new source images.
    """
    if target.is_file():
        if target.suffix.lower() in SUPPORTED_SUFFIXES:
            yield target
        return

    pattern = "**/*" if recursive else "*"

    for candidate in sorted(target.glob(pattern)):
        if is_supported_image(candidate, target):
            yield candidate


def process_image(
    input_path: Path,
    variations: tuple[str, ...],
    overwrite: bool,
) -> None:
    """Create selected variations for one JPEG."""
    try:
        with Image.open(input_path) as opened_image:
            source = opened_image.convert("RGB")
            metadata = preserve_metadata(opened_image)

    except Exception as error:
        print(
            f"Skipped unreadable image: {input_path.name} ({error})",
            file=sys.stderr,
        )
        return

    processors: dict[str, Callable[[Image.Image], Image.Image]] = {
        "fixed": fixed_variation,
        "bw-digital": bw_digital_variation,
        "blownout": blownout_variation,
    }

    print()
    print(f"Source: {input_path.name}")

    for variation in variations:
        output_path = output_path_for(input_path, variation)

        if output_path.exists() and not overwrite:
            print(f"  Skipped existing: {output_path}")
            continue

        try:
            print(f"  Creating: {variation}")
            result = processors[variation](source)

            save_jpeg(result, output_path, metadata)

            print(f"  Saved:    {output_path}")

        except Exception as error:
            print(
                f"  Failed: {variation} ({error})",
                file=sys.stderr,
            )


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Create fixed, digital black-and-white, and blown-out "
            "compact-camera JPEG variations."
        )
    )

    parser.add_argument(
        "target",
        nargs="?",
        default=".",
        help=(
            "JPEG file or folder to process. "
            "Defaults to the current directory."
        ),
    )

    parser.add_argument(
        "--only",
        nargs="+",
        choices=VARIATIONS,
        metavar="VARIATION",
        help=f"Create only selected variations: {', '.join(VARIATIONS)}.",
    )

    parser.add_argument(
        "--recursive",
        action="store_true",
        help="Process JPG/JPEG files in subfolders too.",
    )

    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Replace existing files in edited variation folders.",
    )

    args = parser.parse_args()

    target = Path(args.target).expanduser().resolve()

    if not target.exists():
        fail(f"Target not found: {target}")

    if target.is_file() and target.suffix.lower() not in SUPPORTED_SUFFIXES:
        fail("Input file must be a JPG or JPEG image.")

    variations = tuple(args.only) if args.only else VARIATIONS
    images = list(find_images(target, args.recursive))

    if not images:
        fail("No JPG or JPEG images found.")

    print("============================================================")
    print("CYBERSHOT VARIATIONS")
    print("============================================================")
    print(f"Target:     {target}")
    print(f"Images:     {len(images)}")
    print(f"Variations: {', '.join(variations)}")

    for image_path in images:
        process_image(
            image_path,
            variations,
            args.overwrite,
        )

    print()
    print("Finished.")


if __name__ == "__main__":
    main()
