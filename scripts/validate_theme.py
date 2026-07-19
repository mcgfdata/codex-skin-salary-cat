#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PRESET_ID = "preset-yuexinmiao"
PRESET_IDS = (
    DEFAULT_PRESET_ID,
    "preset-yuexinmiao-payday",
)
MANIFEST_PATH = ROOT / "codex-install.json"
PLUGIN_PATH = ROOT / ".codex-plugin" / "plugin.json"
SOURCE = ROOT / "source" / "salary-cat-source.png"
EXPECTED_PRESET_FILES = {"background.jpg", "theme.json"}
EXPECTED_SOURCE_SIZE = (1942, 809)
EXPECTED_BACKGROUND_SIZES = {
    "preset-yuexinmiao": (2560, 1440),
    "preset-yuexinmiao-payday": (2240, 1600),
}
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


def read_theme(theme_path: Path) -> dict[str, object]:
    try:
        raw = json.loads(theme_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"invalid UTF-8 JSON in {theme_path}: {error}")
    if not isinstance(raw, dict):
        fail("theme.json must contain an object")
    return raw


def validate_install_manifest() -> None:
    version = (ROOT / "VERSION").read_text(encoding="ascii").strip()
    try:
        manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"invalid UTF-8 JSON in {MANIFEST_PATH}: {error}")
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        fail("codex-install.json must use schema version 1")
    if manifest.get("version") != version:
        fail("codex-install.json version does not match VERSION")
    if manifest.get("repository") != "https://github.com/mcgfdata/codex-skin-salary-cat":
        fail("codex-install.json has an unexpected repository")
    author = manifest.get("author")
    if not isinstance(author, dict) or author.get("name") != "终端极客" or author.get("github") != "mcgfdata":
        fail("codex-install.json has an unexpected author")
    theme = manifest.get("theme")
    if not isinstance(theme, dict) or theme.get("id") != DEFAULT_PRESET_ID:
        fail("codex-install.json has an unexpected theme id")
    themes = manifest.get("themes")
    if not isinstance(themes, list) or len(themes) != len(PRESET_IDS):
        fail("codex-install.json must declare both selectable themes")
    declared_ids = [item.get("id") for item in themes if isinstance(item, dict)]
    if declared_ids != list(PRESET_IDS):
        fail("codex-install.json theme order or ids are invalid")
    for index, (item, preset_id) in enumerate(zip(themes, PRESET_IDS, strict=True)):
        if item.get("presetDirectory") != f"presets/{preset_id}":
            fail(f"codex-install.json has an invalid preset directory for {preset_id}")
        if item.get("default") is not (index == 0):
            fail(f"codex-install.json has an invalid default flag for {preset_id}")
    selection = manifest.get("selection")
    if not isinstance(selection, dict) or selection.get("defaultThemeId") != DEFAULT_PRESET_ID:
        fail("codex-install.json has an invalid theme selection contract")
    runtime = manifest.get("runtime")
    if not isinstance(runtime, dict) or runtime.get("schemaVersion") != 1:
        fail("codex-install.json has an invalid runtime declaration")
    bootstrap = manifest.get("bootstrap")
    if not isinstance(bootstrap, dict):
        fail("codex-install.json must declare the fresh-user bootstrap")
    if bootstrap.get("systemSkill") != "skill-installer":
        fail("fresh-user bootstrap must use the built-in skill-installer")
    if bootstrap.get("repositoryPath") != "skills/codex-skin-salary-cat":
        fail("fresh-user bootstrap has an invalid Skill path")
    if bootstrap.get("continueInCurrentTask") is not True:
        fail("fresh-user bootstrap must continue in the current task")
    trigger_prompt = bootstrap.get("triggerPrompt", "")
    if (
        "设置 Codex 皮肤" not in trigger_prompt
        or "skill-installer" in trigger_prompt
        or "安装" in trigger_prompt
    ):
        fail("public trigger prompt must remain setup-only")
    platforms = manifest.get("platforms")
    if not isinstance(platforms, dict):
        fail("codex-install.json must declare platform setup commands")
    if platforms.get("macos", {}).get("fullSetupCommand") != "./Setup.command":
        fail("codex-install.json has an invalid macOS setup command")
    if "theme-backup.json" not in platforms.get("macos", {}).get("detectRuntimeMarker", ""):
        fail("codex-install.json must declare the macOS runtime completion marker")
    if platforms.get("macos", {}).get("automaticResumeAfterQuit") is not True:
        fail("macOS setup must resume automatically after Codex quits")
    if platforms.get("macos", {}).get("restartPolicy") != "one-confirmation-auto-restart":
        fail("macOS setup must declare its one-confirmation restart policy")
    macos_theme_dirs = platforms.get("macos", {}).get("themeDirectories")
    if not isinstance(macos_theme_dirs, list) or not all(
        directory.endswith(preset_id)
        for directory, preset_id in zip(macos_theme_dirs, PRESET_IDS, strict=False)
    ) or len(macos_theme_dirs) != len(PRESET_IDS):
        fail("codex-install.json has invalid macOS theme directories")
    if "Setup.ps1" not in platforms.get("windows", {}).get("fullSetupCommand", ""):
        fail("codex-install.json has an invalid Windows setup command")
    if "appearance.json" not in platforms.get("windows", {}).get("detectRuntimeMarker", ""):
        fail("codex-install.json must declare the Windows runtime completion marker")
    windows_theme_dirs = platforms.get("windows", {}).get("themeDirectories")
    if not isinstance(windows_theme_dirs, list) or not all(
        directory.endswith(preset_id)
        for directory, preset_id in zip(windows_theme_dirs, PRESET_IDS, strict=False)
    ) or len(windows_theme_dirs) != len(PRESET_IDS):
        fail("codex-install.json has invalid Windows theme directories")
    dependencies = manifest.get("dependencies")
    if not isinstance(dependencies, dict):
        fail("codex-install.json must declare installation dependencies")
    if dependencies.get("gitRequired") is not False or dependencies.get("administratorRequired") is not False:
        fail("installation must not require Git or administrator access")
    windows_dependencies = dependencies.get("automaticallyInstalled", {}).get("windows", [])
    if "Node.js 22" not in windows_dependencies:
        fail("Windows must declare automatic Node.js 22 installation")

    try:
        plugin = json.loads(PLUGIN_PATH.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"invalid UTF-8 JSON in {PLUGIN_PATH}: {error}")
    if plugin.get("name") != "codex-skin-salary-cat" or plugin.get("version") != version:
        fail("plugin metadata does not match the package name and version")
    if plugin.get("skills") != "./skills/":
        fail("plugin must expose the standard skills directory")

    for skill_path in (
        ROOT / "SKILL.md",
        ROOT / "skills" / "codex-skin-salary-cat" / "SKILL.md",
    ):
        skill = skill_path.read_text(encoding="utf-8")
        if not skill.startswith("---\nname: codex-skin-salary-cat\n"):
            fail(f"invalid skill frontmatter: {skill_path}")
        if "mcgfdata/codex-skin-salary-cat" not in skill or "终端极客" not in skill:
            fail(f"skill trigger is missing repository or author: {skill_path}")

    for setup_path in (
        ROOT / "Setup.command",
        ROOT / "Setup.ps1",
        ROOT / "scripts" / "finish-setup-macos.sh",
        ROOT / "scripts" / "setup-skin-macos.sh",
        ROOT / "skills" / "codex-skin-salary-cat" / "scripts" / "bootstrap-macos.sh",
        ROOT / "skills" / "codex-skin-salary-cat" / "scripts" / "bootstrap-windows.ps1",
    ):
        if not setup_path.is_file():
            fail(f"full setup entry is missing: {setup_path}")

    macos_setup = (ROOT / "scripts" / "setup-skin-macos.sh").read_text(encoding="utf-8")
    macos_finish = (ROOT / "scripts" / "finish-setup-macos.sh").read_text(encoding="utf-8")
    windows_setup = (ROOT / "Setup.ps1").read_text(encoding="utf-8-sig")
    if "git clone" in macos_setup or "git.exe" in windows_setup:
        fail("full setup must not require Git")
    if "SHASUMS256.txt" not in windows_setup or "Get-FileHash" not in windows_setup:
        fail("Windows portable Node.js download must verify the official SHA-256")
    if "launchctl submit" not in macos_setup or "finish-setup-macos.sh" not in macos_setup:
        fail("macOS first-time setup must delegate completion to launchd")
    if "stop_codex true" not in macos_finish or "--no-launch" not in macos_finish:
        fail("macOS deferred setup must reuse the upstream safe restart workflow")
    if "launchctl remove" not in macos_finish:
        fail("macOS deferred setup must unregister its one-shot launchd job")
    if DEFAULT_PRESET_ID not in macos_finish or "ACTIVE_THEME_JSON" not in macos_finish:
        fail("macOS deferred setup must require and verify the active Salary Cat theme")
    for preset_id in PRESET_IDS:
        if preset_id not in macos_setup or preset_id not in macos_finish:
            fail(f"macOS setup does not stage and verify {preset_id}")


def validate_text(theme: dict[str, object], key: str, maximum: int) -> None:
    value = theme.get(key)
    if not isinstance(value, str) or not value.strip() or len(value) > maximum:
        fail(f"{key} must be a non-empty string up to {maximum} characters")
    if any(ord(character) < 32 for character in value):
        fail(f"{key} must be a single line without control characters")


def validate_preset(preset_id: str) -> int:
    preset_dir = ROOT / "presets" / preset_id
    if not preset_dir.is_dir():
        fail(f"missing preset directory: {preset_dir}")
    actual_files = {path.name for path in preset_dir.iterdir() if path.is_file()}
    if actual_files != EXPECTED_PRESET_FILES:
        fail(
            f"{preset_id} must contain exactly {sorted(EXPECTED_PRESET_FILES)}, "
            f"got {sorted(actual_files)}"
        )
    if any(path.is_symlink() for path in preset_dir.iterdir()):
        fail(f"{preset_id} files and directories must not be symbolic links")

    theme = read_theme(preset_dir / "theme.json")
    if theme.get("schemaVersion") != 1:
        fail("schemaVersion must be 1")
    if theme.get("id") != preset_id:
        fail(f"theme id must be {preset_id}")
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

    image_path = preset_dir / "background.jpg"
    image_bytes = image_path.stat().st_size
    if not 0 < image_bytes <= MAX_IMAGE_BYTES:
        fail("background.jpg must be non-empty and no larger than 16 MB")
    with Image.open(image_path) as image:
        image.load()
        expected_size = EXPECTED_BACKGROUND_SIZES[preset_id]
        if image.format != "JPEG" or image.size != expected_size:
            fail(f"{preset_id} background must be a {expected_size[0]}x{expected_size[1]} JPEG")
        if image.width * image.height > MAX_IMAGE_PIXELS:
            fail("background exceeds the 50-megapixel runtime limit")
    return image_bytes


def validate_theme(release: bool) -> None:
    validate_install_manifest()
    preset_dirs = {
        path.name
        for path in (ROOT / "presets").iterdir()
        if path.is_dir() and path.name.startswith("preset-")
    }
    if preset_dirs != set(PRESET_IDS):
        fail(f"expected presets {sorted(PRESET_IDS)}, got {sorted(preset_dirs)}")

    image_sizes = {preset_id: validate_preset(preset_id) for preset_id in PRESET_IDS}

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
    summary = ", ".join(f"{preset_id} ({image_sizes[preset_id]} bytes)" for preset_id in PRESET_IDS)
    print(f"theme validation passed ({mode}): {summary}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate the Salary Cat Dream Skin presets.")
    parser.add_argument("--release", action="store_true", help="also require approved artwork rights")
    args = parser.parse_args()
    validate_theme(release=args.release)


if __name__ == "__main__":
    main()
