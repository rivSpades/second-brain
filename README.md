# Second Brain

Personal second brain for AI agents (Cursor, Claude Code, Codex, etc.).

Loaded via `LOADER.md` from global pointers (`~/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`).

## Layout

| Path | Role |
|------|------|
| `LOADER.md` | On/off switch + load order |
| `index.md` | Routing — read first |
| `AGENTS.md` | Ingest / query / lint rules |
| `context/` | Cross-tool context (not skills) |
| `skills/` | Invocable skills |
| `raw/` | Immutable source captures |
| `wiki/` | Syntheses derived from `raw/` |
| `log.md` | Append-only history |

## Toggle

Use the `brain-toggle` skill (`liga o brain` / `desliga o brain` / `brain status`).
