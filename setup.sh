#!/usr/bin/env bash
# One-shot setup for this OpenClaw workspace.
#   ./setup.sh
#
# Idempotent — safe to re-run after editing configs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_LINK="${HOME}/.openclaw/workspace"

say() { printf '\n\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m!! \033[0m %s\n' "$*" >&2; }
die() { printf '\n\033[1;31mxx \033[0m %s\n' "$*" >&2; exit 1; }

# 1. Node version check
say "Checking Node.js"
if ! command -v node >/dev/null 2>&1; then
  die "Node not found. Install Node 22.19+ (24 recommended)."
fi
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [[ "$NODE_MAJOR" -lt 22 ]]; then
  die "Node ${NODE_MAJOR} too old. Need 22.19+ (24 recommended)."
fi
echo "node $(node -v) ok"

# 2. Claude Code CLI check (the `coder` agent needs it)
say "Checking Claude Code CLI (for the coder agent)"
if ! command -v claude >/dev/null 2>&1; then
  warn "claude CLI not found. Install with:"
  warn "    npm install -g @anthropic-ai/claude-code"
  warn "The coder agent will fail to delegate until this is installed."
else
  echo "claude $(claude --version 2>/dev/null || echo 'present') ok"
fi

# 3. OpenClaw install
say "Checking OpenClaw"
if ! command -v openclaw >/dev/null 2>&1; then
  say "Installing openclaw globally"
  npm install -g openclaw@latest
fi
echo "openclaw $(openclaw --version 2>/dev/null || echo 'present') ok"

# 4. Onboard + install daemon (idempotent — openclaw skips if already done)
say "Running openclaw onboard"
openclaw onboard --install-daemon || warn "onboard returned non-zero; continuing"

# 5. Link this repo as the workspace
say "Linking workspace ${WORKSPACE_LINK} -> ${REPO_ROOT}"
mkdir -p "${HOME}/.openclaw"
if [[ -L "$WORKSPACE_LINK" ]]; then
  CURRENT_TARGET="$(readlink "$WORKSPACE_LINK")"
  if [[ "$CURRENT_TARGET" != "$REPO_ROOT" ]]; then
    warn "Existing symlink points to ${CURRENT_TARGET}. Replacing."
    rm "$WORKSPACE_LINK"
    ln -s "$REPO_ROOT" "$WORKSPACE_LINK"
  else
    echo "symlink already correct"
  fi
elif [[ -e "$WORKSPACE_LINK" ]]; then
  BACKUP="${WORKSPACE_LINK}.bak.$(date +%s)"
  warn "${WORKSPACE_LINK} exists and is not a symlink. Backing up to ${BACKUP}"
  mv "$WORKSPACE_LINK" "$BACKUP"
  ln -s "$REPO_ROOT" "$WORKSPACE_LINK"
else
  ln -s "$REPO_ROOT" "$WORKSPACE_LINK"
fi

# 6. Run doctor to migrate config to canonical shape
say "Running openclaw doctor --fix"
openclaw doctor --fix || warn "doctor reported issues — read the output above"

# 7. Restart gateway so it picks up the new workspace
say "Restarting gateway"
openclaw gateway restart || openclaw gateway --port 18789 --verbose &

# 8. Status
say "Gateway status"
openclaw gateway status --deep || true

cat <<'EOF'

==============================================================
 Setup complete. Next steps:

   1. Log in to your model provider:
        openclaw auth login anthropic
        # (uses $ANTHROPIC_API_KEY if set)

   2. Try a CLI ping:
        openclaw run claw "ping"

   3. Wire a channel — edit examples/openclaw.<channel>.json
      then flip `enabled: true` in openclaw.json and run:
        openclaw doctor --fix && openclaw gateway restart

   4. Run Claude Code side-by-side any time:
        claude              # interactive
        # or let @coder delegate non-interactively via tools/claude-code.sh
==============================================================
EOF
