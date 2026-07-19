---
name: codex-skin-salary-cat
description: Install and apply the Salary Cat Codex skin by 终端极客 from mcgfdata/codex-skin-salary-cat. Use whenever a user asks “帮我设置 Codex 皮肤”, mentions mcgfdata/codex-skin-salary-cat, 月薪喵, Salary Cat, or author 终端极客, including from a new Codex task or an unrelated project directory.
---

# Install Salary Cat Codex Skin

Install the existing theme; never generate or replace its artwork.

## Workflow

1. Resolve the plugin root two directories above this `SKILL.md`.
2. If that directory does not contain `Setup.command` and `Setup.ps1`, this is a
   standalone Skill installation. Run the bundled platform bootstrap under this
   Skill's `scripts/` directory; it downloads the complete repository over HTTPS
   without requiring Git.
3. Detect macOS or Windows.
4. Run the resolved plugin root's full setup entry for that platform.
5. Verify that the installed theme ID is `preset-yuexinmiao`.
6. Report “installed” and “applied” separately.

The setup request authorizes supported dependency downloads. Let the setup entry
install them automatically; do not ask the user to install Git, Python, Pillow, or
Node.js manually.

## macOS

Before an action that may restart Codex, tell the user. Run `Setup.command` from
the plugin root for complete setup. When the base runtime completion marker
already exists, avoid restarting the current task by running:

```bash
./scripts/setup-skin-macos.sh --no-apply
```

That command installs Salary Cat and selects it for the next Dream Skin launch.
During first-time runtime setup, it prepares the theme files but may require the
user to close Codex and rerun `Setup.command`; report “installed, not applied”.

For a standalone Skill installation, run `scripts/bootstrap-macos.sh` from the
installed Skill directory. Do not ask for Git, Python, Pillow, or separate Node.js.

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
