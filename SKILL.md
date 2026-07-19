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

For normal setup, run:

```bash
./Setup.command
```

If the runtime is missing while Codex is open, this entry presents one native
confirmation and delegates the remaining work to a one-shot `launchd` job. It safely
closes Codex through the upstream runtime, completes setup, applies Salary Cat, and
reopens Codex automatically. Never ask the user to run a command after closing Codex.

Only when the user explicitly asks not to restart, prepare without applying:

```bash
./scripts/setup-skin-macos.sh --no-apply
```

Report that this opt-out leaves first-time runtime setup incomplete.

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
