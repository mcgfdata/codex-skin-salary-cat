# Codex Agent Installation Instructions

These instructions apply to the entire repository.

## Trigger

When a user asks Codex to install or set up the skin from
`mcgfdata/codex-skin-salary-cat`, treat that as a request to install the
existing Salary Cat theme. The project author is `终端极客`.

Do not generate, replace, or add artwork. This repository intentionally uses
only `source/salary-cat-source.png`.

## Goal

Install `preset-yuexinmiao` into the local Codex Dream Skin theme library and,
when the compatible base runtime is already available, apply it. This theme
pack never patches the official Codex application.

Read `codex-install.json` before running commands.

## Procedure

1. Confirm the current operating system and that the checkout is this repository.
2. Check whether the Codex Dream Skin base runtime is installed.
3. If it is installed, run the bundled installer for the current platform.
4. If it is missing, obtain the base runtime only from
   `https://github.com/Fei-Away/Codex-Dream-Skin` and follow its platform README.
5. Verify that the installed `theme.json` has the ID `preset-yuexinmiao`.
6. Report separately whether the theme was installed and whether it was applied.

## macOS

Base runtime detection:

```bash
test -x "$HOME/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh"
```

If it is already installed, run from this repository:

```bash
./scripts/install-theme-macos.sh
```

To install the theme without risking a Codex restart during the current task:

```bash
./scripts/install-theme-macos.sh --no-apply
```

If the base runtime is missing, clone the upstream repository to a temporary
directory, inspect its current macOS README, and install with:

```bash
./macos/scripts/install-dream-skin-macos.sh --no-launch
```

Then install this theme. Applying a newly installed runtime may restart Codex;
finish all file work first and tell the user before the final apply/restart step.

Installed theme verification:

```bash
/usr/bin/plutil -extract id raw -o - \
  "$HOME/Library/Application Support/CodexDreamSkinStudio/themes/preset-yuexinmiao/theme.json"
```

## Windows

Base runtime detection:

```powershell
Test-Path "$env:LOCALAPPDATA\CodexDreamSkin\engine\scripts\theme-windows.ps1"
```

If it is already installed, run from this repository:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
```

If the base runtime is missing, clone the upstream repository to a temporary
directory and follow `windows/README.md`. Its first-time installer requires the
official Codex process to be closed. Prepare the command for the user and state
this limitation clearly; do not claim completion while Codex is still open.

Installed theme verification:

```powershell
$theme = Get-Content `
  "$env:LOCALAPPDATA\CodexDreamSkin\themes\preset-yuexinmiao\theme.json" `
  -Raw -Encoding UTF8 | ConvertFrom-Json
$theme.id
```

## Safety

- Do not request administrator access for this theme pack.
- Do not modify `.app`, `app.asar`, WindowsApps, Codex signatures, API keys, or provider settings.
- Do not download a Dream Skin runtime from mirrors or unofficial forks.
- Keep the user informed before any action that can close or restart Codex.
