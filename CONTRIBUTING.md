# Contributing

Thanks for helping improve the Salary Cat theme.

## Project scope

- Keep exactly one source image: `source/salary-cat-source.png`.
- Keep exactly one installable preset: `preset-yuexinmiao`.
- Do not add a second subject, generated replacement art, UI screenshots, logos, or watermarks.
- Keep the preset compatible with Codex Dream Skin schema version 1.
- Do not copy the Codex Dream Skin runtime into this repository.

## Before opening a pull request

```bash
python3 -m pip install -r requirements.txt
python3 scripts/build_presets.py
python3 scripts/validate_theme.py
bash -n Install.command scripts/install-theme-macos.sh
```

Windows installer changes should also be tested in Windows PowerShell 5.1 and PowerShell 7.

Do not change `ASSET_STATUS` to `approved` unless the actual artwork rights holder has completed `ASSET-LICENSE.md`.
