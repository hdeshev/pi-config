# Pi Configuration (`~/.pi`)

## Package Management

All tooling is installed globally via **Bun**:

```
~/.bun/install/global/node_modules/
```

### Currently installed global packages

| Package | Purpose |
|---|---|
| `@mariozechner/pi-coding-agent` | Pi coding agent |
| `@anthropic-ai/claude-agent-sdk` | Claude agent SDK |
| `@ast-grep/cli` | Structural code search (ast-grep) |
| `@fission-ai/openspec` | OpenSpec spec-driven development |
| `context-mode` | Context window optimization |
| `megamemory` | Long-term memory / knowledge base |
| `pi-mcporter` | MCP tool proxy |
| `pi-acp` | ACP adapter for agent-shell Emacs integration |

## How Pi agent settings reference bun packages

Pi's `agent/settings.json` uses **relative paths** to global bun packages via the `packages` array:

```json
"packages": [
  "../../.bun/install/global/node_modules/context-mode",
  "../../.bun/install/global/node_modules/pi-mcporter"
]
```

These paths resolve from `~/.pi/agent/` to `~/.bun/install/global/node_modules/<pkg>`.

For MCP servers, the `agent/mcp.json` references commands by their binary name (since bun global `bin/` is on `PATH`):

```json
{
  "mcpServers": {
    "context-mode": {
      "command": "context-mode"
    }
  }
}
```

## Upgrade Commands

### Upgrade Pi

```bash
bun install -g @mariozechner/pi-coding-agent@latest
```

### Upgrade all global bun packages

```bash
bun update -g
```

This resolves latest versions for all globally installed packages and updates them in one shot.
