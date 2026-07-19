# Changelog

All notable changes to this project are recorded here.

## 0.3.2 - 2026-07-19

- Added the selectable `月薪喵 · 今日营业` banner layout from the same source artwork.
- Save both Salary Cat presets together while keeping `月薪喵` as the default.
- Expose both styles in Dream Skin's saved-theme library without replacing unrelated themes.
- Added one-confirmation macOS setup with automatic quit, completion, theme apply, and relaunch.
- Delegated first-time completion to a one-shot `launchd` job so users never run a command after quitting Codex.
- Reused the upstream Dream Skin identity checks and safe restart workflow for deferred setup.

## 0.3.1 - 2026-07-19

- Added a fresh-user self-bootstrap contract for the built-in `skill-installer`.
- Treat the public “设置 Codex 皮肤” wording as authorization for the complete flow.
- Continue from Skill retrieval to the platform bootstrap in the same task, with an HTTPS archive fallback.

## 0.3.0 - 2026-07-19

- Removed Git as an installation prerequisite by using official HTTPS archives.
- Added automatic, SHA-256-verified user-level Node.js 22 installation on Windows.
- Added self-contained Skill bootstrap scripts for macOS and Windows.
- Documented install-time, rebuild-only, and non-automatable prerequisites.
- Added validated runtime completion markers so interrupted first-time setup resumes correctly.

## 0.2.0 - 2026-07-19

- Added a root Codex Skill and plugin manifest for repository-based discovery.
- Added full setup entry points that install the official Dream Skin prerequisite when missing.
- Added no-apply and dry-run paths so an agent can finish safely before restarting Codex.

## 0.1.0 - 2026-07-19

- Added the single-image `preset-yuexinmiao` theme pack.
- Added double-click installers for macOS and Windows.
- Added reproducible preset generation, validation, and release packaging.
- Declared compatibility with Codex Dream Skin theme schema version 1.
- Added `AGENTS.md` and `codex-install.json` so Codex can guide repository-based installation.
