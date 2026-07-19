# Salary Cat Codex Skin

[中文](./README.md) · English

Author: 终端极客 · [GitHub repository](https://github.com/mcgfdata/codex-skin-salary-cat)

A two-layout, single-image theme pack for [Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin).

| Salary Cat (default) | Salary Cat · Open Today (banner) |
|---|---|
| <img src="./presets/preset-yuexinmiao/background.jpg" alt="Default Salary Cat layout preview"> | <img src="./presets/preset-yuexinmiao-payday/background.jpg" alt="Salary Cat Open Today banner layout preview"> |

> This lightweight package does not bundle the Dream Skin runtime and does not modify the official Codex installation. The full setup entry obtains the prerequisite only from its official upstream repository when needed.

## Let Codex install it

In a new Codex task, send:

```text
帮我设置 Codex 皮肤 mcgfdata/codex-skin-salary-cat，作者是终端极客
```

The public prompt is sufficient on its own. Repository guidance tells Codex to self-bootstrap [`skills/codex-skin-salary-cat`](./skills/codex-skin-salary-cat/SKILL.md) when it is missing, then continue with the bundled platform bootstrap in the same task. A first-time runtime setup may require closing or restarting Codex.

On macOS, first-time setup shows one native confirmation, then automatically closes Codex, completes the official Dream Skin configuration in a one-shot background job, applies Salary Cat, and reopens Codex. Users never need to run a command after quitting the app.

Both layouts are saved together. `月薪喵` remains the default, and users can switch to `月薪喵 · 今日营业` from Dream Skin's saved-theme menu without repeating setup.

See [`INSTALL_WITH_CODEX.md`](./INSTALL_WITH_CODEX.md) for the full agent-facing flow.

## Compatibility

- Theme format: Codex Dream Skin schema version 1
- Validated with the upstream `1.2.0` runtime payload checker
- Platforms: macOS and Windows
- Theme IDs: `preset-yuexinmiao` (default) and `preset-yuexinmiao-payday` (banner)
- Theme libraries: macOS `~/Library/Application Support/CodexDreamSkinStudio/themes/`; Windows `%LOCALAPPDATA%\CodexDreamSkin\themes\`

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

The installer validates both presets and publishes them together without touching unrelated saved themes. It applies the default Salary Cat layout when a compatible runtime is available; otherwise, it only adds both layouts to the saved-theme library.

To install without applying:

```bash
./scripts/install-theme-macos.sh --no-apply
```

```powershell
.\Install.ps1 -NoApply
```

On macOS, if Gatekeeper blocks the first launch, right-click `Install.command` in Finder and choose Open. Administrator access is not required.

## Single-image composition

The repository only uses [`source/salary-cat-source.png`](./source/salary-cat-source.png). It does not add another subject or image; the layout reference screenshot is never packaged as an asset.

The `1942 × 809` source is approximately `2.40:1`. The default layout is `2560 × 1440` and crops roughly 26% of the horizontal frame, mostly left-side whitespace, to enlarge the subject. The banner layout is `2240 × 1600` (`1.40:1`): it preserves the full source width and bottom-aligns it on a sampled pale canvas. Staying below Dream Skin's `1.45` wide-art expansion threshold keeps the native home hero card, while explicit `taskMode: banner` enables the task-page banner. Neither layout uses inpainting or creates image detail.

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
  --output dist/codex-skin-salary-cat-0.3.2.zip
```

## License and notice

- Code and documentation: MIT, see [`LICENSE`](./LICENSE)
- Artwork: CC BY 4.0, see [`ASSET-LICENSE.md`](./ASSET-LICENSE.md)
- Additional notices: [`NOTICE.md`](./NOTICE.md)
- This is not an official OpenAI product

When using or redistributing the artwork, retain the attribution “月薪喵主题作者：终端极客”.
