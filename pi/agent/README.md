# Pi Agent Setup

This directory is linked by Home Manager to `~/.pi/agent`.

## Installed Packages

- `pi-rewind`: checkpoints and `/rewind` undo flow.
- `pi-subagents`: scout, planner, worker, reviewer, researcher, and related agent workflows.
- `pi-mcp-adapter`: token-efficient MCP proxy and `/mcp` UI.
- `pi-usage`: `/usage` for token and quota visibility.
- `pi-opencode-bridge`: OpenCode Go/Zen providers for Pi.
- `@ff-labs/pi-fff`: FFF-backed file and content search, configured in `override` mode.

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
/thinking [off|minimal|low|medium|high|xhigh]
/fff-health
/reload-runtime
```

`fffind` and `ffgrep` replace Pi's built-in `find` and `grep` tools. `/fff-health` reports the local FFF index status.

`Ctrl+T` cycles thinking level. `Ctrl+Shift+T` keeps the built-in collapse/expand thinking-block toggle.

## Local Resources

- `AGENTS.md`: global Pi behavior instructions.
- `extensions/`: local safety, status, reload, and thinking-level extensions.
- `skills/`: reusable workflow instructions, including the ported OpenCode `beads.md` workflow.
- `prompts/`: prompt templates.
- `themes/`: custom themes, including `kanagawa-paper-ink`.
- `memory/`: tracked starter memory files; generated daily logs and notes are ignored.

## Secrets

Do not commit `auth.json`, API keys, package installs, sessions, caches, or generated logs. These are ignored by `.gitignore`.
