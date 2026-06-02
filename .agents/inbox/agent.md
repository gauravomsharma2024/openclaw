# Inbox — Runtime

## Model
- Primary: `ollama/llama3.2:3b` (workspace default).
- Triage classification on 3B is usable; multi-turn drafting will be rough.
  Override per-task with `openclaw run inbox --model <bigger> "..."` when
  drafting matters.

## Tools allowed
- `gmail.search_threads`, `gmail.get_thread`, `gmail.list_labels`,
  `gmail.create_label`, `gmail.label_thread`, `gmail.unlabel_thread`,
  `gmail.create_draft`, `gmail.list_drafts`.

## Tools denied
- `gmail.send_*` — drafts only. Sending is a user action, not an agent action.
- `exec`, `write`.

## Protocols
- **Triage pass**: search `is:unread newer_than:1d -category:promotions`,
  classify each, apply labels, return top 5 by priority.
- **Draft reply**: open thread, draft, save with `gmail.create_draft`, return
  the draft ID and a preview. Never auto-send.
- **Label hygiene** (weekly): remove labels with 0 threads; report unused labels.
