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
| `context-mode` | Context window optimization |
| `pi-mcporter` | MCP tool proxy |
| `mcporter` | MCP tool proxy CLI |
| `@plannotator/pi-extension` | Plannotator extension |
| `opencode-ai` | Opencode AI |
| `repomix` | Repository packer |

## How Pi agent settings reference bun packages

Pi's `agent/settings.json` uses **relative paths** to global bun packages via the `packages` array:

```json
"packages": [
  "../../.bun/install/global/node_modules/@plannotator/pi-extension",
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
