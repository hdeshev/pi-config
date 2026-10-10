# Pi Configuration (`~/.pi`)

## Package Management

Pi and its tooling are installed globally with **pnpm**:

```
~/.local/share/pnpm/
```

### Currently installed global packages

| Package | Purpose |
|---|---|
| `@earendil-works/pi-coding-agent` | Pi coding agent |
| `@agentclientprotocol/claude-agent-acp` | ACP adapter for Claude Agent |
| `@fission-ai/openspec` | OpenSpec spec-driven development |
| `likec4` | LikeC4 architecture modeling |
| `pi-acp` | ACP adapter for agent-shell Emacs integration |
| `tsx` | TypeScript runner |

## How Pi agent settings reference packages

Pi's `agent/settings.json` declares packages in the `packages` array using
`npm:` and `git:` sources:

```json
"packages": [
  "npm:context-mode",
  "npm:pi-mcporter",
  "git:github.com/DietrichGebert/ponytail"
]
```

npm packages resolve through the pnpm workspace in `agent/npm/`; git packages
clone under `agent/git/`.

For MCP servers, `agent/mcp.json` points `command` at a binary — an absolute
path into `agent/npm/node_modules/.bin/`, or a globally installed command on
`PATH`:

```json
{
  "mcpServers": {
    "context-mode": {
      "command": "/home/hd/.pi/agent/npm/node_modules/.bin/context-mode"
    }
  }
}
```

## Upgrade Commands

### Upgrade Pi

```bash
pi update          # Pi only (default)
pi update --all    # Pi and all extensions
```

Or install the latest globally with pnpm:

```bash
pnpm add -g @earendil-works/pi-coding-agent@latest
```

### Upgrade all global packages

```bash
pnpm update -g
```

This resolves latest versions for all globally installed packages and updates them in one shot.
