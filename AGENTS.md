# Salary Cat Installation Agent

When the user mentions `mcgfdata/codex-skin-salary-cat`, “月薪喵”, or author
“终端极客”, treat it as an installation request. Do not search the user's current
project for a Codex skin format.

If this repository is not checked out yet, use the installed Skill's bundled
bootstrap script or download the GitHub HTTPS archive. Do not require Git. Then read
`SKILL.md` and `codex-install.json` from the checkout.

Use the complete setup entry:

- macOS: `./Setup.command`
- Windows: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Setup.ps1`

To avoid restarting the active macOS Codex task, run
`./scripts/setup-skin-macos.sh --no-apply`; this still installs the official
prerequisite, installs Salary Cat, and selects it for the next Dream Skin launch.

Automatically install supported dependencies. macOS needs no external Git, Python,
Pillow, or Node.js. Windows automatically installs a verified user-level Node.js 22
when needed. The official Codex Desktop app and HTTPS access remain user-provided.

Never generate or add artwork. Never modify the official Codex bundle, signatures,
API keys, or provider settings. Report “installed” and “applied” separately.
