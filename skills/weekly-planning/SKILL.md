---
name: weekly-planning
description: >-
  Use when the user asks to "plan my week", "weekly planning",
  "daycare schedule", "plan drop-off and pickup", or wants to
  do weekly life planning including daycare logistics.
argument-hint: []
---

Plan Leo's daycare drop-off and pickup schedule for the week, then create events on the shared "Lucy & Andrew" Google Calendar.

## Steps

### 1. Get current date and determine the target week

Call `get-current-time` with timezone `America/New_York`. Determine the target Monday–Friday:
- If today is a weekday and the week hasn't ended, plan for the remainder of the current week.
- If it's the weekend, plan for the following Monday–Friday.
- If it's ambiguous, ask the user which week they want to plan.

### 2. Check for existing daycare events

Call `list-events` on calendar `Lucy & Andrew` for the target week (Monday 00:00 through Friday 23:59), timezone `America/New_York`.

Look for events with titles containing "Dropoff" or "Pickup" combined with "Daycare" or "Home". If any already exist:
- Show the existing events to the user.
- Ask whether to **skip** those days, **replace** them (delete + recreate), or **proceed anyway** (create duplicates).

### 3. Collect the week's schedule

Use `AskUserQuestion` to ask who handles each handoff. Present all 5 days at once. Use `multiSelect: false` with one question per day-slot, or a compact layout — whichever fits best.

**Defaults:**
- **Monday, Tuesday, Thursday, Friday:** Lucy for both morning and evening (@ Daycare)
- **Wednesday:** Gigi for both morning and evening (@ Home)

For each day, collect:
- **Morning** handoff person (Lucy / Andrew / Gigi)
- **Evening** handoff person (Lucy / Andrew / Gigi)

If the user says "defaults are fine" or similar, accept all defaults without further questions.

### 4. Confirm the full plan

Display a summary table before creating any events:

```
Week of {Month Day, Year}:

  Mon: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
  Tue: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
  Wed: Gigi - Pickup @ Home (8:00 AM)     | Gigi - Dropoff @ Home (5:00 PM)
  Thu: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
  Fri: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
```

Ask: "Does this look right, or would you like to change anything?"

Iterate until the user approves.

### 5. Create Google Calendar events

For each day, create 2 events on the "Lucy & Andrew" calendar. Make all `create-event` calls in parallel where possible.

**Calendar ID:** `bcjlfb5ui948dc914cerjil94g@group.calendar.google.com`
**Timezone:** `America/New_York`

**Title construction logic:**

Morning event:
- If person is Gigi: `Gigi - Pickup @ Home` (she picks Leo up from home)
- Otherwise: `{Person} - Dropoff @ Daycare`

Evening event:
- If person is Gigi: `Gigi - Dropoff @ Home` (she drops Leo off at home)
- Otherwise: `{Person} - Pickup @ Daycare`

**Event times:**
- Morning (Daycare / Lucy or Andrew): `start` = `YYYY-MM-DDT07:45:00`, `end` = `YYYY-MM-DDT08:15:00`
- Morning (Gigi / Home): `start` = `YYYY-MM-DDT08:00:00`, `end` = `YYYY-MM-DDT08:15:00`
- Evening (Daycare / Lucy or Andrew): `start` = `YYYY-MM-DDT17:00:00`, `end` = `YYYY-MM-DDT17:30:00`
- Evening (Gigi / Home): `start` = `YYYY-MM-DDT17:00:00`, `end` = `YYYY-MM-DDT17:15:00`

### 6. Report summary

Show a final summary with:
- Total events created
- Each event with its Google Calendar link (from the `htmlLink` in the create response)
- Reminder that they can re-run `/weekly-planning` next week

## Notes

- **People options:** Andrew (parent), Lucy (parent), Gigi (grandma — watches Leo on Wednesdays at home)
- **Location logic:** Gigi → `@ Home`; anyone else → `@ Daycare`
- On Gigi days the morning action is "Pickup" (she picks Leo up from home) and the evening action is "Dropoff" (she drops him off at home). On daycare days the morning action is "Dropoff" and the evening action is "Pickup".
