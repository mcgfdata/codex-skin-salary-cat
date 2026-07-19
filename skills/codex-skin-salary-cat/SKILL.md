---
name: codex-skin-salary-cat
description: Install and apply the Salary Cat Codex skin by 终端极客 from mcgfdata/codex-skin-salary-cat. Use whenever a user asks “帮我设置 Codex 皮肤”, mentions mcgfdata/codex-skin-salary-cat, 月薪喵, Salary Cat, or author 终端极客, including from a new Codex task or an unrelated project directory.
---

# Install Salary Cat Codex Skin

Install the existing theme; never generate or replace its artwork.

## Workflow

1. Resolve the plugin root two directories above this `SKILL.md`.
2. If that directory does not contain `Setup.command` and `Setup.ps1`, this is a
   standalone Skill installation. Clone
   `https://github.com/mcgfdata/codex-skin-salary-cat.git` to a temporary
   directory and use that checkout as the plugin root.
3. Detect macOS or Windows.
4. Run the resolved plugin root's full setup entry for that platform.
5. Verify that the installed theme ID is `preset-yuexinmiao`.
6. Report “installed” and “applied” separately.

## macOS

Before an action that may restart Codex, tell the user. Run `Setup.command` from
the plugin root for complete setup. To avoid restarting the current task, run:

```bash
./scripts/setup-skin-macos.sh --no-apply
```

That command installs the official prerequisite when missing, installs Salary
Cat, and selects it for the next Dream Skin launch.

## Windows

Run `Setup.ps1` from the plugin root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Setup.ps1
```

The first prerequisite install requires Codex to be closed. If it is open,
prepare the command and clearly tell the user to close Codex and run `Setup.cmd`.

## Safety

- Obtain the prerequisite only from `https://github.com/Fei-Away/Codex-Dream-Skin`.
- Do not modify official Codex files, signatures, API keys, or provider settings.
- Do not request administrator access.
