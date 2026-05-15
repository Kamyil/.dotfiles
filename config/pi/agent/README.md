# Pi Agent Setup

This directory is linked by Home Manager to `~/.pi/agent`.

## Installed Packages

- `pi-rewind`: checkpoints and `/rewind` undo flow.
- `pi-subagents`: scout, planner, worker, reviewer, researcher, and related agent workflows.
- `pi-mcp-adapter`: token-efficient MCP proxy and `/mcp` UI.
- `pi-usage`: `/usage` for token and quota visibility.
- `pi-opencode-bridge`: OpenCode Go/Zen providers for Pi.

## First Run

Inside Pi:

```text
/login
/opencode-go-key <key>
/opencode-status
/model
```

Select `oc-sdk-go/...` for OpenCode Go models or `oc-sdk-zen/...` for Zen models.

## Useful Commands

```text
/rewind
/agents
/mcp
/usage
/reload-runtime
```

## Local Resources

- `AGENTS.md`: global Pi behavior instructions.
- `extensions/`: local safety, status, and reload extensions.
- `skills/`: reusable workflow instructions.
- `prompts/`: prompt templates.
- `themes/`: custom themes.
- `memory/`: tracked starter memory files; generated daily logs and notes are ignored.

## Secrets

Do not commit `auth.json`, API keys, package installs, sessions, caches, or generated logs. These are ignored by `.gitignore`.
