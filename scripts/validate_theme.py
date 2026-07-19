#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
PRESET_ID = "preset-yuexinmiao"
MANIFEST_PATH = ROOT / "codex-install.json"
PRESET_DIR = ROOT / "presets" / PRESET_ID
SOURCE = ROOT / "source" / "salary-cat-source.png"
THEME_PATH = PRESET_DIR / "theme.json"
EXPECTED_PRESET_FILES = {"background.jpg", "theme.json"}
EXPECTED_SOURCE_SIZE = (1942, 809)
EXPECTED_BACKGROUND_SIZE = (2560, 1440)
MAX_IMAGE_BYTES = 16 * 1024 * 1024
MAX_IMAGE_PIXELS = 50_000_000
REQUIRED_COLORS = {
    "background",
    "panel",
    "panelAlt",
    "accent",
    "accentAlt",
    "secondary",
    "highlight",
    "text",
    "muted",
    "line",
}
HEX_COLOR = re.compile(r"^#[0-9a-fA-F]{6}$")
RGBA_COLOR = re.compile(r"^rgba?\([0-9., %]+\)$")


def fail(message: str) -> None:
    raise SystemExit(f"theme validation failed: {message}")


def read_theme() -> dict[str, object]:
    try:
        raw = json.loads(THEME_PATH.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"invalid UTF-8 JSON in {THEME_PATH}: {error}")
    if not isinstance(raw, dict):
        fail("theme.json must contain an object")
    return raw


def validate_install_manifest() -> None:
    try:
        manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"invalid UTF-8 JSON in {MANIFEST_PATH}: {error}")
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        fail("codex-install.json must use schema version 1")
    if manifest.get("repository") != "https://github.com/mcgfdata/codex-skin-salary-cat":
        fail("codex-install.json has an unexpected repository")
    author = manifest.get("author")
    if not isinstance(author, dict) or author.get("name") != "终端极客" or author.get("github") != "mcgfdata":
        fail("codex-install.json has an unexpected author")
    theme = manifest.get("theme")
    if not isinstance(theme, dict) or theme.get("id") != PRESET_ID:
        fail("codex-install.json has an unexpected theme id")
    runtime = manifest.get("runtime")
    if not isinstance(runtime, dict) or runtime.get("schemaVersion") != 1:
        fail("codex-install.json has an invalid runtime declaration")


def validate_text(theme: dict[str, object], key: str, maximum: int) -> None:
    value = theme.get(key)
    if not isinstance(value, str) or not value.strip() or len(value) > maximum:
        fail(f"{key} must be a non-empty string up to {maximum} characters")
    if any(ord(character) < 32 for character in value):
        fail(f"{key} must be a single line without control characters")


def validate_theme(release: bool) -> None:
    validate_install_manifest()
    if not PRESET_DIR.is_dir():
        fail(f"missing preset directory: {PRESET_DIR}")
    actual_files = {path.name for path in PRESET_DIR.iterdir() if path.is_file()}
    if actual_files != EXPECTED_PRESET_FILES:
        fail(f"preset must contain exactly {sorted(EXPECTED_PRESET_FILES)}, got {sorted(actual_files)}")
    if any(path.is_symlink() for path in PRESET_DIR.iterdir()):
        fail("preset files and directories must not be symbolic links")

    theme = read_theme()
    if theme.get("schemaVersion") != 1:
        fail("schemaVersion must be 1")
    if theme.get("id") != PRESET_ID:
        fail(f"theme id must be {PRESET_ID}")
    if theme.get("image") != "background.jpg":
        fail("image must be the local filename background.jpg")
    if theme.get("appearance") not in {"auto", "light", "dark"}:
        fail("appearance must be auto, light, or dark")

    for key, maximum in {
        "id": 80,
        "name": 80,
        "brandSubtitle": 80,
        "tagline": 160,
        "projectPrefix": 80,
        "projectLabel": 80,
        "statusText": 80,
        "quote": 80,
    }.items():
        validate_text(theme, key, maximum)

    art = theme.get("art")
    if not isinstance(art, dict):
        fail("art must be an object")
    for key in ("focusX", "focusY"):
        value = art.get(key)
        if not isinstance(value, (int, float)) or isinstance(value, bool) or not 0 <= value <= 1:
            fail(f"art.{key} must be a number from 0 to 1")
    if art.get("safeArea") not in {"auto", "left", "right", "center", "none"}:
        fail("art.safeArea is invalid")
    if art.get("taskMode") not in {"auto", "ambient", "banner", "off"}:
        fail("art.taskMode is invalid")

    colors = theme.get("colors")
    if not isinstance(colors, dict) or set(colors) != REQUIRED_COLORS:
        fail(f"colors must contain exactly {sorted(REQUIRED_COLORS)}")
    for key, value in colors.items():
        if not isinstance(value, str):
            fail(f"colors.{key} must be a string")
        pattern = RGBA_COLOR if key == "line" else HEX_COLOR
        if not pattern.fullmatch(value):
            fail(f"colors.{key} has an unsupported format: {value!r}")

    image_path = PRESET_DIR / "background.jpg"
    image_bytes = image_path.stat().st_size
    if not 0 < image_bytes <= MAX_IMAGE_BYTES:
        fail("background.jpg must be non-empty and no larger than 16 MB")
    with Image.open(image_path) as image:
        image.load()
        if image.format != "JPEG" or image.size != EXPECTED_BACKGROUND_SIZE:
            fail(f"background must be a {EXPECTED_BACKGROUND_SIZE[0]}x{EXPECTED_BACKGROUND_SIZE[1]} JPEG")
        if image.width * image.height > MAX_IMAGE_PIXELS:
            fail("background exceeds the 50-megapixel runtime limit")

    with Image.open(SOURCE) as source:
        source.load()
        if source.format != "PNG" or source.size != EXPECTED_SOURCE_SIZE:
            fail(f"source must be a {EXPECTED_SOURCE_SIZE[0]}x{EXPECTED_SOURCE_SIZE[1]} PNG")

    source_images = [
        path for path in (ROOT / "source").iterdir()
        if path.is_file() and path.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}
    ]
    if source_images != [SOURCE]:
        fail("source/ must contain exactly one image: salary-cat-source.png")

    if release:
        license_text = (ROOT / "ASSET-LICENSE.md").read_text(encoding="utf-8")
        if not re.search(r"<!--\s*ASSET_STATUS:\s*approved\s*-->", license_text):
            fail("ASSET-LICENSE.md is not approved for public release")
        if "TODO" in license_text:
            fail("ASSET-LICENSE.md still contains TODO fields")

    mode = "release" if release else "development"
    print(f"theme validation passed ({mode}): {PRESET_ID}, {image_bytes} bytes")


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate the Salary Cat Dream Skin preset.")
    parser.add_argument("--release", action="store_true", help="also require approved artwork rights")
    args = parser.parse_args()
    validate_theme(release=args.release)


if __name__ == "__main__":
    main()
