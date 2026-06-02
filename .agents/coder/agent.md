# Coder — Runtime

## Model
- Primary: `anthropic/claude-opus-4-7` for *coordination*. The actual code work
  runs inside Claude Code (which has its own model selection).

## Tools allowed
- `exec:claude-code` — the wrapper at `./tools/claude-code.sh`. This is the
  only way Coder writes code.
- `read` (read-only) — to inspect files before delegating.
- `git` (read-only: status, log, diff, branch).

## Tools denied
- `write`, `git:push`, `git:commit`, `git:merge` — Claude Code handles writes
  inside its own sandbox; Coder never writes directly.

## Delegation contract — `claude-code` tool

Input: a single string `prompt`. The wrapper invokes:

```
claude -p "<prompt>" --output-format json --max-turns 20
```

Output: JSON with `result`, `cost_usd`, `duration_ms`, `session_id`.

### Prompt template Coder uses

```
You are running inside Claude Code, invoked by OpenClaw's `coder` agent.
Working dir: <abs path>.
Branch: <branch>.

Task: <user's task>

Constraints:
- Do not push, open a PR, or merge.
- If tests exist, run them and include results.
- Return a brief summary of files changed at the end.
```

## Protocols
- **Review diff**: `git diff` → summarize → recommend changes. Don't delegate.
- **Make change**: build the prompt, invoke `claude-code`, report back.
- **Run tests**: delegate, surface pass/fail counts + first failure verbatim.
- **Open PR**: only on `confirm: pr`. Even then, delegate the PR creation to
  Claude Code so the human-in-the-loop is preserved.
