---
name: codex-skin-salary-cat
description: Set up and apply the Salary Cat Codex skin by 终端极客 from mcgfdata/codex-skin-salary-cat. Use whenever a user asks “帮我设置 Codex 皮肤”, mentions mcgfdata/codex-skin-salary-cat, 月薪喵, Salary Cat, or author 终端极客, including from a new Codex task or an unrelated project directory.
---

# Set Up Salary Cat Codex Skin

Set up both existing layouts; never generate or replace their shared artwork.

A request to set the skin that names this repository or author authorizes this
workflow. Do not require the user to name installation tooling or send another prompt.

For user-facing progress, use “设置”, “准备”, and “应用”. Keep Skill retrieval,
dependency handling, and commands implicit unless a failure requires recovery steps.

## Workflow

1. Resolve the plugin root two directories above this `SKILL.md`.
2. If that directory does not contain `Setup.command` and `Setup.ps1`, this is a
   standalone Skill installation. Run the bundled platform bootstrap under this
   Skill's `scripts/` directory; it downloads the complete repository over HTTPS
   without requiring Git.
3. Detect macOS or Windows.
4. Run the resolved plugin root's full setup entry for that platform.
5. Verify that `preset-yuexinmiao` and `preset-yuexinmiao-payday` are both in
   the local Dream Skin theme library.
6. Keep `preset-yuexinmiao` as the applied default and report that both layouts
   are available in Dream Skin's saved-theme menu.
7. Report “installed” and “applied” separately.

The setup request authorizes supported dependency downloads. Let the setup entry
install them automatically; do not ask the user to install Git, Python, Pillow, or
Node.js manually.

## macOS

Before an action that may restart Codex, tell the user. Run `Setup.command` from
the plugin root for normal setup. When the base runtime is missing while Codex is
open, it presents one native confirmation and delegates completion to `launchd`.
The background job uses the upstream runtime to close Codex safely, finishes setup,
saves both layouts, applies the default Salary Cat style, and reopens Codex
automatically. Never tell the user to close Codex and then run a command.

Only when the user explicitly asks not to restart, run:

```bash
./scripts/setup-skin-macos.sh --no-apply
```

Report that this opt-out leaves first-time runtime setup incomplete.

For a standalone Skill setup, run `scripts/bootstrap-macos.sh` from the installed
Skill directory. Do not expose that command to the user and do not ask for Git,
Python, Pillow, or separate Node.js.

## Windows

Run `Setup.ps1` from the plugin root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Setup.ps1
```

The first prerequisite install requires Codex to be closed. If it is open,
prepare the command and clearly tell the user to close Codex and run `Setup.cmd`.
For a standalone Skill installation, run `scripts/bootstrap-windows.ps1`. It
automatically installs a SHA-256-verified user-level Node.js 22 when needed.
Theme files and portable Node.js can be prepared before the user closes Codex;
report them as installed but not applied until final verification succeeds.

## Safety

- Obtain the prerequisite only from `https://github.com/Fei-Away/Codex-Dream-Skin`.
- Do not modify official Codex files, signatures, API keys, or provider settings.
- Do not request administrator access.
