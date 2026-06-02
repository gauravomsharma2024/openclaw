# Chat Coordinator — Runtime

## Model
- Primary: `anthropic/claude-haiku-4-5-20251001` (cheap, fast — it just routes).

## Tools allowed
- `slack.send_message`, `slack.get_thread` (per-channel scoped).
- `discord.send_message`, `discord.get_thread`.
- `telegram.send_message`, `telegram.get_chat`.
- `agent.handoff` — invoke another registered agent with a given message.

## Tools denied
- `exec`, `write`, `gmail.*`, `calendar.*` (those belong to specialists).

## Protocols
- **On inbound message**: classify, ack in ≤ 1 sentence, `agent.handoff` to
  the right specialist with the original message body.
- **VIP DM**: skip routing, push a notification, do not auto-ack.
- **Multi-domain message**: pick the *first* applicable specialist, mention
  the second in the ack: "Routing to @inbox; will loop in @scheduler after."
