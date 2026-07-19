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

The setup request authorizes downloading the declared supported dependencies. Run
the setup entry and let it install them; do not send the user away to install Git,
Python, Pillow, or Node.js manually.

If this skill was invoked from a GitHub reference but is not installed locally, fetch
the repository's HTTPS source archive with system tools; do not require Git. Then run
the setup entry from that checkout.

## macOS

The user's setup request authorizes installing the official prerequisite from
`Fei-Away/Codex-Dream-Skin`. Before an action that may restart Codex, tell the user.
Do not ask for Git, Python, Pillow, or a separate Node.js installation on macOS.

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
and run `Setup.cmd`. Setup still installs the theme files and portable Node.js before
that handoff. Do not claim the theme was applied before verification.
Automatically install a verified user-level Node.js 22 when no compatible Node is in
`PATH`; do not ask the user to install it manually.

## Safety

- Use the upstream runtime only from `https://github.com/Fei-Away/Codex-Dream-Skin`.
- Do not modify the official Codex bundle, `app.asar`, WindowsApps, signatures, API keys, or provider settings.
- Do not request administrator access for this theme.
