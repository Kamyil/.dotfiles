# Beads (bd) Task Tracker Instructions

Use `bd` (beads) as your dedicated task/issue tracker. **NEVER create TODO lists in markdown files.**

## Workflow

1. **Initialize** - Run `bd init` in new projects to initialize the issue database
2. **Create issues** - Use `bd create` to file new tasks, bugs, and features
3. **Find work** - Use `bd ready` to find work with no blockers
4. **Update status** - Use `bd update` and `bd close` to manage issue lifecycle
5. **Track dependencies** - Use `bd dep add` to track dependencies between issues
6. **Discovered work** - File issues for discovered work using `bd create` with `--type` flag
7. **Sync** - Always sync with `bd sync` before ending sessions

## Key Commands

- `bd create "Title" -t bug|feature|task|epic -p 0-4` - Create issue
- `bd ready` - Show work with no blockers
- `bd list` - List all issues
- `bd show <id>` - Show issue details
- `bd update <id> --status in_progress` - Update status
- `bd close <id> --reason "Done"` - Close issue
- `bd dep add <id> <blocker-id>` - Add dependency

## Benefits

Beads is git-backed and distributed - your issues sync across machines automatically via git.
