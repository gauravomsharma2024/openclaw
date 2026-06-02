# User context — Chat Coordinator

- **VIPs** (always surface, never auto-route):
  - (Name) — Slack ID `U…`
  - (Name) — Telegram ID `…`

## Channels I want active
Enable per channel by setting `enabled: true` in `examples/openclaw.<channel>.json`.

- Slack: workspace + channel IDs go in `examples/openclaw.slack.json`.
- Discord: server + channel IDs in `examples/openclaw.discord.json`.
- Telegram: chat IDs in `examples/openclaw.telegram.json`.

## Quiet hours
- Mute auto-acks 22:00–08:00 IST. Notifications only.
