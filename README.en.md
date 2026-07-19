# Salary Cat Codex Skin

[中文](./README.md) · English

Author: 终端极客 · [GitHub repository](https://github.com/mcgfdata/codex-skin-salary-cat)

A single-image theme pack for [Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin).

<p align="center">
  <img src="./presets/preset-yuexinmiao/background.jpg" alt="Salary Cat theme background preview" width="900">
</p>

> This lightweight package does not bundle the Dream Skin runtime and does not modify the official Codex installation. The full setup entry obtains the prerequisite only from its official upstream repository when needed.

## Let Codex install it

In a new Codex task, send:

```text
帮我设置 Codex 皮肤 mcgfdata/codex-skin-salary-cat，作者是终端极客
```

The repository is also a standard Codex Plugin and Skill. Codex can install [`skills/codex-skin-salary-cat`](./skills/codex-skin-salary-cat/SKILL.md), use its bundled bootstrap to download the full repository, and run the complete setup entry. A first-time runtime setup may require closing or restarting Codex.

See [`INSTALL_WITH_CODEX.md`](./INSTALL_WITH_CODEX.md) for the full agent-facing flow.

## Compatibility

- Theme format: Codex Dream Skin schema version 1
- Validated with the upstream `1.2.0` runtime payload checker
- Platforms: macOS and Windows
- Install locations:
  - macOS: `~/Library/Application Support/CodexDreamSkinStudio/themes/preset-yuexinmiao`
  - Windows: `%LOCALAPPDATA%\CodexDreamSkin\themes\preset-yuexinmiao`

Future upstream schema changes may require a matching update here.

## Dependencies

Regular installation only requires the official Codex Desktop app and HTTPS network access.

- macOS: no Git, Python, Pillow, or separate Node.js is required. Setup uses system `curl` / `ditto`, and Dream Skin reuses Codex's bundled Node.
- Windows: no Git or Python is required. When Node.js 22+ is unavailable, Setup downloads the matching x64/ARM64 archive from nodejs.org, verifies its official SHA-256, installs it for the current user, and updates the user PATH.
- Administrator access is not required on either platform.

Python 3.10 and Pillow are rebuild-only dependencies for maintainers; users do not need them to install the skin.

If Codex is running during first-time setup, `Setup` prepares all safe dependency and theme-file steps before asking the user to close Codex. Run the same entry again after closing Codex to finish the base runtime and apply the theme; setup does not bypass upstream `config.toml` protections.

## Install

1. Download and fully extract the ZIP from Releases, or let the Skill bootstrap download it. Git is not required.
2. Run the full setup entry, which installs the official prerequisite when missing:
   - macOS: double-click [`Setup.command`](./Setup.command)
   - Windows: double-click [`Setup.cmd`](./Setup.cmd), or run [`Setup.ps1`](./Setup.ps1)
3. Users who already have the runtime may use `Install.command` / `Install.cmd` for the theme only.

The installer validates the preset before replacing an older copy with the same ID. It applies Salary Cat when a compatible runtime is available; otherwise, it only adds the theme to the saved-theme library.

To install without applying:

```bash
./scripts/install-theme-macos.sh --no-apply
```

```powershell
.\Install.ps1 -NoApply
```

On macOS, if Gatekeeper blocks the first launch, right-click `Install.command` in Finder and choose Open. Administrator access is not required.

## Single-image composition

The repository only uses [`source/salary-cat-source.png`](./source/salary-cat-source.png). It does not add another subject or image.

The `1942 × 809` source is approximately `2.40:1`, while the Dream Skin background is `2560 × 1440` (`16:9`). The current crop discards roughly 26% of the horizontal frame, almost entirely from the left-side empty space, then scales an effective area of about `1438 × 809` to `2560 × 1440`. It preserves the Salary Cat subject and a usable native-UI safe area, but it does not create real image detail. No inpainting or additional artwork is used.

## Rebuild and validate

Python 3.10 or newer is required:

```bash
python3 -m pip install -r requirements.txt
python3 scripts/build_presets.py
python3 scripts/validate_theme.py
```

Public releases also require the artwork-rights check:

```bash
python3 scripts/validate_theme.py --release
```

Build an install-only ZIP with:

```bash
python3 scripts/package_release.py \
  --output dist/codex-skin-salary-cat-0.3.0.zip
```

## License and notice

- Code and documentation: MIT, see [`LICENSE`](./LICENSE)
- Artwork: CC BY 4.0, see [`ASSET-LICENSE.md`](./ASSET-LICENSE.md)
- Additional notices: [`NOTICE.md`](./NOTICE.md)
- This is not an official OpenAI product

When using or redistributing the artwork, retain the attribution “月薪喵主题作者：终端极客”.
