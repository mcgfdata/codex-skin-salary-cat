#!/usr/bin/env python3
from __future__ import annotations

import argparse
import stat
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PACKAGE_FILES = [
    "AGENTS.md",
    "ASSET-LICENSE.md",
    "AUTHORS.md",
    "CHANGELOG.md",
    "Install.cmd",
    "Install.command",
    "Install.ps1",
    "INSTALL_WITH_CODEX.md",
    "LICENSE",
    "NOTICE.md",
    "README.en.md",
    "README.md",
    "VERSION",
    "codex-install.json",
    "presets/preset-yuexinmiao/background.jpg",
    "presets/preset-yuexinmiao/theme.json",
    "scripts/install-theme-macos.sh",
    "scripts/install-theme-windows.ps1",
]
EXECUTABLE_FILES = {"Install.command", "scripts/install-theme-macos.sh"}
ZIP_TIMESTAMP = (2026, 1, 1, 0, 0, 0)


def package(output: Path) -> None:
    version = (ROOT / "VERSION").read_text(encoding="ascii").strip()
    package_root = f"codex-skin-salary-cat-{version}"
    output.parent.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for relative in sorted(PACKAGE_FILES):
            source = ROOT / relative
            if not source.is_file():
                raise SystemExit(f"release file is missing: {source}")
            info = zipfile.ZipInfo(f"{package_root}/{relative}", date_time=ZIP_TIMESTAMP)
            info.create_system = 3
            mode = stat.S_IFREG | (0o755 if relative in EXECUTABLE_FILES else 0o644)
            info.external_attr = mode << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, source.read_bytes(), compresslevel=9)

    print(f"wrote {output}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build the install-only release ZIP.")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    package(args.output.resolve())


if __name__ == "__main__":
    main()
