# AGENTS.md

This repository is the **Pi coding agent configuration** (`~/.pi`) — a dotfiles-style
repo versioning configuration, skills, and extensions for `@mariozechner/pi-coding-agent`.
Everything lives under `agent/`: `settings.json` (gitignored; see `settings.json.example`),
`models.json` (custom models/providers), `mcp.json`, extensions (notably `claude-skills.ts`),
skills (mostly .NET/C# and Emacs), and a pnpm workspace in `agent/npm/` for npm packages.
`context-mode/`, `pi-acp/`, `agent/sessions/`, and other runtime state are gitignored.

Packages are loaded via the `"packages"` array in `agent/settings.json`
(`npm:context-mode`, `npm:pi-mcporter`, `npm:mcporter`, `npm:pi-acp`,
`git:github.com/obra/superpowers`), resolved through the pnpm workspace.
`README.md` is the source of truth for installed tooling and upgrade commands.

Conventions: never commit secrets or runtime state (all listed in `.gitignore`);
model/provider changes go in `agent/models.json`; skills live in `agent/skills/<name>/SKILL.md`;
keep `settings.json.example` in sync when the settings structure changes.