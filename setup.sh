#!/usr/bin/env bash
# One-shot setup for this OpenClaw workspace.
#   ./setup.sh
#
# Idempotent. Designed for a machine where openclaw is already installed
# and onboarded. Will not upgrade openclaw or overwrite your existing
# ~/.openclaw/openclaw.json without backing it up first.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_HOME="${HOME}/.openclaw"
WORKSPACE_LINK="${OPENCLAW_HOME}/workspace"
CONFIG_LINK="${OPENCLAW_HOME}/openclaw.json"
STAMP="$(date +%Y%m%d-%H%M%S)"

say()  { printf '\n\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m!! \033[0m %s\n' "$*" >&2; }
die()  { printf '\n\033[1;31mxx \033[0m %s\n' "$*" >&2; exit 1; }

# 1. Node version check
say "Checking Node.js"
command -v node >/dev/null 2>&1 || die "Node not found. Need 22.19+ (24 recommended)."
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[[ "$NODE_MAJOR" -ge 22 ]] || die "Node ${NODE_MAJOR} too old. Need 22.19+."
echo "node $(node -v) ok"

# 2. OpenClaw — install only if missing. Do NOT auto-upgrade.
say "Checking OpenClaw"
if ! command -v openclaw >/dev/null 2>&1; then
  say "openclaw not found — installing latest"
  npm install -g openclaw@latest
else
  echo "openclaw $(openclaw --version 2>/dev/null || echo 'present') already installed — leaving as-is"
fi

# 3. Ollama / llama3.2:3b sanity check (workspace default model)
say "Checking Ollama + llama3.2:3b (the workspace default model)"
if command -v ollama >/dev/null 2>&1; then
  if ollama list 2>/dev/null | grep -q '^llama3.2:3b'; then
    echo "ollama has llama3.2:3b ok"
  else
    warn "ollama is installed but llama3.2:3b is not pulled. Run: ollama pull llama3.2:3b"
  fi
else
  warn "ollama CLI not found. The agents won't run until ollama is reachable."
  warn "If your ollama runs in Docker/remote, ignore this and ensure the daemon endpoint is set in ~/.openclaw/openclaw.json."
fi

# 4. Onboard (idempotent — skips if already done)
say "Running openclaw onboard (idempotent)"
openclaw onboard --install-daemon || warn "onboard returned non-zero; continuing"

# 5. Link the workspace markdown directory
say "Linking workspace: ${WORKSPACE_LINK} -> ${REPO_ROOT}"
mkdir -p "$OPENCLAW_HOME"
link_path() {
  # $1 = link path, $2 = target
  local link="$1" target="$2"
  if [[ -L "$link" ]]; then
    local current; current="$(readlink "$link")"
    if [[ "$current" == "$target" ]]; then
      echo "  $link already correctly linked"
      return
    fi
    warn "  $link points to $current — replacing"
    rm "$link"
  elif [[ -e "$link" ]]; then
    local backup="${link}.bak.${STAMP}"
    warn "  $link exists (not a symlink). Backing up to $backup"
    mv "$link" "$backup"
  fi
  ln -s "$target" "$link"
  echo "  linked: $link -> $target"
}
link_path "$WORKSPACE_LINK" "$REPO_ROOT"

# 6. Link openclaw.json (per your choice — back up your existing config first)
say "Linking runtime config: ${CONFIG_LINK} -> ${REPO_ROOT}/openclaw.json"
link_path "$CONFIG_LINK" "${REPO_ROOT}/openclaw.json"
echo
echo "  NOTE: Your previous ~/.openclaw/openclaw.json (if any) is preserved"
echo "        as ${CONFIG_LINK}.bak.${STAMP}. Inspect it for settings you"
echo "        want to port over (especially the ollama endpoint URL if you"
echo "        customised it):"
echo "          diff ${CONFIG_LINK}.bak.* ${REPO_ROOT}/openclaw.json"

# 7. Migrate to canonical shape
say "Running openclaw doctor --fix"
openclaw doctor --fix || warn "doctor reported issues — read the output above and adjust openclaw.json"

# 8. Restart gateway so it picks up the new workspace + config
say "Restarting gateway"
openclaw gateway restart || openclaw gateway --port 18789 --verbose &

# 9. Status
say "Gateway status"
openclaw gateway status --deep || true

cat <<EOF

==============================================================
 Setup complete.

 Default model:   ollama/llama3.2:3b
 Agents enabled:  claw, webmaster, inbox, scheduler, chat-coord
 Agents disabled: coder (needs Claude Code + ANTHROPIC_API_KEY)
 Channels:        cli only (slack/discord/telegram templates ready but off)

 Try it:
     openclaw run claw      "ping"
     openclaw run scheduler "any free time tomorrow afternoon?"
     openclaw run inbox     "list unread from today"

 Run Claude Code in another terminal whenever you need real coding help:
     claude

 To enable the coder agent later:
   1. npm install -g @anthropic-ai/claude-code
   2. export ANTHROPIC_API_KEY=...
   3. Move the "coder" stanza from agents.disabled into agents.list
      in openclaw.json and re-run: openclaw doctor --fix
==============================================================
EOF
