# Personal OpenClaw Workspace

Day-to-day agent fleet for managing my website + blogs + YouTube, email, calendar,
coding work (delegated to Claude Code), and chat channels.

The configs in this repo are the canonical source — `~/.openclaw/workspace` is a
symlink to this checkout. Edit here, commit, push.

## What's in here

```
.
├── soul.md                 # Root persona: "Claw" — the coordinator
├── agents.yaml             # Agent manifest (registry + routing)
├── openclaw.json           # Runtime config (model, agents list, tools)
├── AGENTS.md               # Governance rules for agents working in this repo
├── setup.sh                # One-shot: install daemon, link workspace, doctor
├── .agents/
│   ├── webmaster/          # Website + blog + YouTube channel management
│   ├── inbox/              # Gmail triage & drafting
│   ├── scheduler/          # Calendar wrangling
│   ├── coder/              # Coding tasks — delegates to Claude Code CLI
│   └── chat-coord/         # Routes inbound Slack/Discord/Telegram traffic
├── tools/
│   └── claude-code.sh      # Wrapper invoked by the `coder` agent
└── examples/
    ├── openclaw.slack.json
    ├── openclaw.discord.json
    └── openclaw.telegram.json
```

## First-time setup

```bash
./setup.sh
```

That script will:
1. Verify Node 22.19+ (24 recommended) and `claude` CLI presence.
2. `npm install -g openclaw@latest` if missing.
3. `openclaw onboard --install-daemon`.
4. Symlink `~/.openclaw/workspace` → this repo.
5. `openclaw doctor --fix` (migrate config to the canonical shape).
6. `openclaw gateway status`.

After it finishes, point at the model and key:

```bash
openclaw auth login anthropic       # uses your ANTHROPIC_API_KEY
openclaw config set agent.model anthropic/claude-opus-4-7
```

## Running Claude Code alongside

Two ways, both supported:

- **Manual side-by-side** — just open another terminal and run `claude`. It's
  fully independent and shares the same Anthropic key.
- **Delegated** — ask the `coder` agent ("hey coder, fix the build on
  feature/foo"). It shells out via `tools/claude-code.sh`, which runs
  `claude -p "<prompt>" --output-format json` non-interactively. See
  `.agents/coder/agent.md` for the contract.

## Day-to-day usage

Mention an agent by name in any wired channel, or invoke from CLI:

```bash
openclaw run webmaster   "draft a YouTube description for today's video"
openclaw run inbox       "what's urgent this morning?"
openclaw run scheduler   "find me 45m with Priya next week, afternoons IST"
openclaw run coder       "review the diff on branch feature/landing"
```

## Editing agents

Each agent lives in `.agents/<id>/` with three files:

- `soul.md` — identity, voice, values
- `agent.md` — model override, tools allow-list, protocols
- `user.md` — what *I* care about — domain context, preferences, hot links

Tweak, commit, and `openclaw gateway restart` to reload.
