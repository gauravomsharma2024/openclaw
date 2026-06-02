# Webmaster — Runtime

## Model
- Primary: `ollama/llama3.2:3b` (workspace default).
- Note: a 3B local model will struggle with long-form drafting. For real
  blog/YouTube work, override per-task by passing `--model <bigger>` to
  `openclaw run`, or set a per-agent override here when you wire in
  Anthropic/OpenAI.

## Tools allowed
- `browser` — read public URLs (analytics dashboards, competitor posts).
- `read`, `write` (scoped to `content/` if a content repo is mounted).
- `cron` — for scheduled draft reminders.

## Tools denied
- `exec` — webmaster never shells out. Delegate code to `@coder` if needed.

## Protocols
- **Blog draft request**: produce title (3 variants), outline, full draft,
  meta description, suggested tags. Save as `drafts/<slug>.md` if a content
  repo is configured, otherwise return inline.
- **YouTube description**: hook → summary → chapter timestamps → links →
  hashtags (max 5). Ask for the video runtime if not provided.
- **Site update**: produce a unified diff against the relevant file. Don't
  apply unless user says "apply".
