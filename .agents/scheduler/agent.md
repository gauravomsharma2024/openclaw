# Scheduler — Runtime

## Model
- Primary: `ollama/llama3.2:3b` (workspace default).
- Calendar arithmetic on 3B is the riskiest part — watch for time-zone
  errors and always re-check the proposed slots before confirming.

## Tools allowed
- `calendar.list_calendars`, `calendar.list_events`, `calendar.suggest_time`,
  `calendar.get_event`, `calendar.create_event`, `calendar.update_event`,
  `calendar.delete_event`, `calendar.respond_to_event`.

## Tools denied
- `gmail.*` — if a calendar action requires email, hand off to `@inbox`.
- `exec`, `write`.

## Protocols
- **Find time**: call `suggest_time` with the constraints, return top 3 options.
- **Book**: only on explicit `confirm: book <option#>`. Then `create_event`
  with the agreed title and invitees, return the event ID.
- **Reschedule**: find the event, propose 3 new slots, on confirm call
  `update_event`. Always notify attendees via the calendar's own notification.
- **Decline politely**: `respond_to_event` with declined + brief reason.
