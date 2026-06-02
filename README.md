# Personal OpenClaw Workspace

Day-to-day agent fleet for website + blog + YouTube, email, calendar, and chat
channel routing. Plus a `coder` agent (currently **disabled**) that delegates
to Claude Code when Anthropic is wired up.

The configs in this repo are the canonical source — both `~/.openclaw/workspace`
and `~/.openclaw/openclaw.json` are symlinked here, so editing happens here,
commits to git, and `openclaw gateway restart` makes it live.

## Current setup

- **Model**: `ollama/llama3.2:3b` (workspace default — runs locally via Ollama)
- **Enabled agents**: `claw`, `webmaster`, `inbox`, `scheduler`, `chat-coord`
- **Disabled agent**: `coder` (needs Anthropic key + Claude Code CLI)
- **Channels**: CLI only. Slack/Discord/Telegram templates ready under `examples/`.

A 3B local model is honest about its limits — routing and triage are fine,
long-form drafting and calendar arithmetic will need re-reads. For real
writing work, override per-task with `openclaw run <agent> --model <bigger>`.

## What's in here

```
.
├── soul.md                 # Root persona: "Claw" — the coordinator
├── agents.yaml             # Agent manifest (registry + routing)
├── openclaw.json           # Runtime config (model, agents list, tools)
├── AGENTS.md               # Governance rules for agents working in this repo
├── setup.sh                # Idempotent: install if missing, symlink, doctor
├── .agents/
│   ├── webmaster/          # Website + blog + YouTube channel management
│   ├── inbox/              # Gmail triage & drafting
│   ├── scheduler/          # Calendar wrangling
│   ├── coder/              # DISABLED — Claude Code delegate, kept for later
│   └── chat-coord/         # Routes inbound Slack/Discord/Telegram traffic
├── tools/
│   └── claude-code.sh      # Wrapper invoked by `coder` when enabled
└── examples/
    ├── openclaw.slack.json
    ├── openclaw.discord.json
    └── openclaw.telegram.json
```

## First-time setup on your machine

You already have openclaw 2026.5.28 installed and onboarded with
llama3.2:3b — `setup.sh` is built for that case. It will:

1. Detect openclaw is present and **not** upgrade it.
2. Check that Ollama has `llama3.2:3b` pulled.
3. Re-run `openclaw onboard --install-daemon` (no-op if already done).
4. Symlink `~/.openclaw/workspace` → this repo.
5. Symlink `~/.openclaw/openclaw.json` → `./openclaw.json` (your existing
   one is backed up as `~/.openclaw/openclaw.json.bak.<timestamp>`).
6. `openclaw doctor --fix` to migrate to the canonical config shape.
7. Restart the gateway.

```bash
git clone <repo-url> openclaw
cd openclaw
git checkout claude/festive-meitner-rximu
./setup.sh
```

Then verify:

```bash
openclaw run claw "ping"
openclaw run scheduler "anything free tomorrow afternoon?"
```

After step 5, diff the backup to recover any custom settings (Ollama endpoint
URL, daemon port, etc.) from your old config:

```bash
diff ~/.openclaw/openclaw.json.bak.* ./openclaw.json
```

## Running Claude Code alongside (right now)

Just open another terminal:

```bash
claude
```

That's it. Claude Code is fully independent of OpenClaw and uses your
`ANTHROPIC_API_KEY` directly. You'll have OpenClaw agents (llama-backed) for
day-to-day triage in one pane, and Claude Code for serious coding in another.

## Enabling the `coder` agent later

When you're ready to wire in Anthropic:

```bash
npm install -g @anthropic-ai/claude-code
export ANTHROPIC_API_KEY=sk-ant-...
```

Then in `openclaw.json`, move the entry from `agents.disabled[0].entry` into
`agents.list`, and flip `tools.register[0].enabled` to `true`. Run:

```bash
openclaw doctor --fix
openclaw gateway restart
openclaw run coder "what's on the current branch?"
```

The `coder` agent will then accept tasks and shell out to Claude Code via
`tools/claude-code.sh` (which calls `claude -p "<prompt>" --output-format json`).

## Day-to-day usage

Mention an agent by name in any wired channel, or invoke from CLI:

```bash
openclaw run webmaster "draft a YouTube description for today's video"
openclaw run inbox     "what's urgent this morning?"
openclaw run scheduler "find me 45m with Priya next week, afternoons IST"
```

## Editing agents

Each agent lives in `.agents/<id>/` with three files:

- `soul.md` — identity, voice, values
- `agent.md` — model override, tools allow-list, protocols
- `user.md` — what *I* care about — domain context, preferences, hot links

Tweak, commit, and `openclaw gateway restart` to reload.
