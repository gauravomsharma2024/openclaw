# User context — Coder

- **Default repo root**: `~/code` (override per-task).
- **Active repos** (so Coder can `cd` without asking):
  - `~/code/openclaw` — this workspace
  - (add more)
- **Languages I use most**: TypeScript, Python, Go.
- **Test command convention**:
  - JS/TS: `pnpm test` (fallback `npm test`)
  - Python: `pytest -q`
  - Go: `go test ./...`
- **Commit style**: Conventional Commits (`feat:`, `fix:`, `chore:` …).
- **PR template**: short summary + test plan checklist.

## Claude Code session preferences
- Allow Claude Code to run tests and linters without asking.
- Require confirmation for: `git push`, `gh pr create`, package installs.
