#!/usr/bin/env bash
# Wrapper invoked by the `coder` agent's `exec:claude-code` tool.
# Usage: tools/claude-code.sh "<prompt>"
#
# Returns the JSON output from `claude -p` on stdout. Non-zero exit on failure.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo '{"error":"missing prompt argument"}' >&2
  exit 2
fi

PROMPT="$1"
WORKDIR="${OPENCLAW_CODER_WORKDIR:-$PWD}"
MAX_TURNS="${OPENCLAW_CODER_MAX_TURNS:-20}"

if ! command -v claude >/dev/null 2>&1; then
  echo '{"error":"claude CLI not on PATH. Install: npm i -g @anthropic-ai/claude-code"}' >&2
  exit 3
fi

cd "$WORKDIR"

# --output-format json gives a single JSON object on stdout when done.
# --max-turns caps runaway agent loops.
exec claude \
  -p "$PROMPT" \
  --output-format json \
  --max-turns "$MAX_TURNS"
