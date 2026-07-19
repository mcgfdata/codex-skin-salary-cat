---
name: codex-skin-salary-cat
description: Set up and apply the Salary Cat Codex skin by 终端极客 from mcgfdata/codex-skin-salary-cat. Use whenever a user asks “帮我设置 Codex 皮肤”, mentions mcgfdata/codex-skin-salary-cat, 月薪喵, Salary Cat, or author 终端极客, including from a new Codex task or an unrelated project directory.
---

# Set Up Salary Cat Codex Skin

Set up the existing theme; never generate or replace its artwork.

A request to set the skin that names this repository or author is sufficient
authorization for repository and supported dependency downloads. Do not require the
user to name installation tooling or send a second prompt.

For user-facing progress, use “设置”, “准备”, and “应用”. Keep Skill retrieval,
dependency handling, and commands implicit unless a failure requires recovery steps.

## Workflow

1. If the user-level `codex-skin-salary-cat` Skill is absent, invoke the built-in
   `skill-installer` for `mcgfdata/codex-skin-salary-cat` at
   `skills/codex-skin-salary-cat`. Read the downloaded Skill and continue in this task.
2. If that system Skill is unavailable, fetch this repository's HTTPS source archive
   with system tools and continue from the checkout. Do not require Git.
3. Locate the plugin root and detect macOS or Windows.
4. Run the repository's full setup entry for that platform.
5. Verify `preset-yuexinmiao/theme.json` in the local Dream Skin theme library.
6. Report “installed” and “applied” separately.

The setup request authorizes downloading the declared supported dependencies. Run
the setup entry and let it install them; do not send the user away to install Git,
Python, Pillow, or Node.js manually.

## macOS

The user's setup request authorizes installing the official prerequisite from
`Fei-Away/Codex-Dream-Skin`. Before an action that may restart Codex, tell the user.
Do not ask for Git, Python, Pillow, or a separate Node.js installation on macOS.

For a complete setup that may restart Codex as its final action:

```bash
./Setup.command
```

When the base runtime completion marker already exists, install and select Salary
Cat for the next Dream Skin launch without restarting the current task:

```bash
./scripts/setup-skin-macos.sh --no-apply
```

During first-time runtime setup, this command installs the theme files first. If
Codex is open, report “installed, not applied” and ask the user to close Codex and
rerun `Setup.command`; do not claim the prerequisite is complete.

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
