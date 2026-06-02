# AGENTS.md — governance for this workspace

Telegraph style. Root rules only. Read `.agents/<id>/agent.md` before working
inside a sub-agent's folder.

## Single source of truth
- Edit configs in this repo. `~/.openclaw/workspace` is a symlink here.
- After editing, run `openclaw gateway restart` (or `openclaw doctor --fix`
  if you touched `openclaw.json` shape).

## Don't
- Don't commit credentials. They live in `~/.openclaw/credentials/`.
- Don't add new top-level config keys without checking `openclaw doctor --fix`
  can migrate the canonical shape — see https://docs.openclaw.ai/reference.
- Don't bypass `requireMention` globally. If a channel needs always-on, set it
  per-channel in the relevant `examples/openclaw.<channel>.json`.

## Do
- Keep `soul.md` voice-only. Put model/tool/protocol config in `agent.md`.
- Put user-specific context (URLs, names, preferences) in `user.md` so it can
  be edited without touching the agent's identity.
- Prefer adding a workflow in `.agents/workflows/` over a one-off prompt.

## Adding a new agent
1. Create `.agents/<id>/` with `soul.md`, `agent.md`, `user.md`.
2. Append the entry to `agents.yaml` and `openclaw.json` `agents.list`.
3. `openclaw doctor --fix` then `openclaw gateway restart`.
4. Verify with `openclaw run <id> "ping"`.
