---
name: codex-skin-salary-cat
description: Install and apply the Salary Cat Codex skin by 终端极客 from mcgfdata/codex-skin-salary-cat. Use whenever a user asks “帮我设置 Codex 皮肤”, mentions mcgfdata/codex-skin-salary-cat, 月薪喵, Salary Cat, or author 终端极客, including from a new Codex task or an unrelated project directory.
---

# Install Salary Cat Codex Skin

Install the existing theme; never generate or replace its artwork.

## Workflow

1. Locate this skill directory. Do not search the user's current project for a skin format.
2. Detect macOS or Windows.
3. Run the repository's full setup entry for that platform.
4. Verify `preset-yuexinmiao/theme.json` in the local Dream Skin theme library.
5. Report “installed” and “applied” separately.

If this skill was invoked from a GitHub reference but is not installed locally, clone
`https://github.com/mcgfdata/codex-skin-salary-cat.git` to a temporary directory first,
then run the setup entry from that checkout.

## macOS

The user's setup request authorizes installing the official prerequisite from
`Fei-Away/Codex-Dream-Skin`. Before an action that may restart Codex, tell the user.

For a complete setup that may restart Codex as its final action:

```bash
./Setup.command
```

To finish the current task without restarting Codex, install everything and select
Salary Cat for the next Dream Skin launch:

```bash
./scripts/setup-skin-macos.sh --no-apply
```

Verify:

```bash
/usr/bin/plutil -extract id raw -o - \
  "$HOME/Library/Application Support/CodexDreamSkinStudio/themes/preset-yuexinmiao/theme.json"
```

## Windows

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Setup.ps1
```

The first base-runtime install requires the official Codex process to be closed. If
it is open, prepare the checkout and command, then clearly ask the user to close Codex
and run `Setup.cmd`. Do not claim the theme was applied before verification.

## Safety

- Use the upstream runtime only from `https://github.com/Fei-Away/Codex-Dream-Skin`.
- Do not modify the official Codex bundle, `app.asar`, WindowsApps, signatures, API keys, or provider settings.
- Do not request administrator access for this theme.
