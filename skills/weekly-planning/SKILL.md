---
name: weekly-planning
description: >-
  Use when the user asks to "plan my week", "weekly planning",
  "daycare schedule", "plan drop-off and pickup", or wants to
  do weekly life planning including daycare logistics.
argument-hint: []
---

Plan Leo's daycare drop-off/pickup schedule and bedtime schedule for the week, then create events on the shared "Lucy & Andrew" Google Calendar.

## Steps

### 1. Get current date and determine the target week

Call `get-current-time` with timezone `America/New_York`. Determine the target week:
- **Daycare (Mon–Fri):** If today is a weekday and the week hasn't ended, plan for the remainder. If it's the weekend, plan for the following Monday–Friday.
- **Bedtime (Mon–Sun):** Always plan all 7 days of the target week.
- If it's ambiguous, ask the user which week they want to plan.

### 2. Check for existing events

Call `list-events` on calendar `Lucy & Andrew` for the target week (Monday 00:00 through Sunday 23:59), timezone `America/New_York`.

**Daycare events:** Look for titles containing "Dropoff" or "Pickup" combined with "Daycare" or "Home". If any already exist:
- Show the existing events to the user.
- Ask whether to **skip** those days, **replace** them (delete + recreate), or **proceed anyway** (create duplicates).

**Bedtime events:** Look for titles containing "Bedtime". If any already exist:
- Show the existing events to the user.
- Ask whether to **skip** those days, **replace** them (delete + recreate), or **proceed anyway** (create duplicates).

### 3. Look up last week's bedtime schedule

Call `list-events` on calendar `Lucy & Andrew` for the **previous** week (Monday 00:00 through Sunday 23:59), timezone `America/New_York`. Look for events with "Bedtime" in the title.

Extract the person (Lucy / Andrew / Both) from each day's bedtime event to use as the default for this week's bedtime schedule.

**If no prior week bedtime events are found:** Generate a random default where Lucy gets 3 days, Andrew gets 3 days, and 1 day is "Both" (randomize which days get which assignment).

### 4. Collect the week's schedule

Use `AskUserQuestion` to collect the schedule. Present daycare and bedtime together.

#### Daycare (Mon–Fri)

**Defaults:**
- **Monday, Tuesday, Thursday, Friday:** Lucy for both morning and evening (@ Daycare)
- **Wednesday:** Gigi for both morning and evening (@ Home)

For each weekday, collect:
- **Morning** handoff person (Lucy / Andrew / Gigi)
- **Evening** handoff person (Lucy / Andrew / Gigi)

#### Bedtime (Mon–Sun)

**Defaults:** Copy last week's schedule (or use the random default from step 3).

For each day, collect:
- **Bedtime** person (Lucy / Andrew / Both)

Present the bedtime defaults clearly and ask: "Last week's bedtime schedule was [schedule]. Any changes this week?"

If the user says "defaults are fine" or similar, accept all defaults without further questions.

### 5. Confirm the full plan

Display a summary table before creating any events:

```
Week of {Month Day, Year}:

  DAYCARE
  Mon: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
  Tue: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
  Wed: Gigi - Pickup @ Home (7:45 AM)     | Gigi - Dropoff @ Home (5:00 PM)
  Thu: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)
  Fri: Lucy - Dropoff @ Daycare (7:45 AM) | Lucy - Pickup @ Daycare (5:00 PM)

  BEDTIME (7:00 PM)
  Mon: Lucy      Thu: Andrew
  Tue: Andrew    Fri: Lucy
  Wed: Both      Sat: Andrew
                 Sun: Lucy
```

Ask: "Does this look right, or would you like to change anything?"

Iterate until the user approves.

### 6. Create Google Calendar events

Create all events on the "Lucy & Andrew" calendar. Make all `create-event` calls in parallel where possible.

**Calendar ID:** `bcjlfb5ui948dc914cerjil94g@group.calendar.google.com`
**Timezone:** `America/New_York`

#### Daycare events (Mon–Fri) — 2 per day

**Title construction logic:**

Morning event:
- If person is Gigi: `Gigi - Pickup @ Home` (she picks Leo up from home)
- Otherwise: `{Person} - Dropoff @ Daycare`

Evening event:
- If person is Gigi: `Gigi - Dropoff @ Home` (she drops Leo off at home)
- Otherwise: `{Person} - Pickup @ Daycare`

**Event times:**
- Morning (Daycare / Lucy or Andrew): `start` = `YYYY-MM-DDT07:45:00`, `end` = `YYYY-MM-DDT08:15:00`
- Morning (Gigi / Home): `start` = `YYYY-MM-DDT07:45:00`, `end` = `YYYY-MM-DDT08:15:00`
- Evening (Daycare / Lucy or Andrew): `start` = `YYYY-MM-DDT17:00:00`, `end` = `YYYY-MM-DDT17:30:00`
- Evening (Gigi / Home): `start` = `YYYY-MM-DDT17:00:00`, `end` = `YYYY-MM-DDT17:30:00`

#### Bedtime events (Mon–Sun) — 1 per day

**Title:** `{Person} - Bedtime` (e.g., "Lucy - Bedtime", "Andrew - Bedtime", "Both - Bedtime")

**Event times:** `start` = `YYYY-MM-DDT19:00:00`, `end` = `YYYY-MM-DDT19:30:00`

### 7. Report summary

Show a final summary with:
- Total events created (daycare + bedtime)
- Each event with its Google Calendar link (from the `htmlLink` in the create response)
- Reminder that they can re-run `/weekly-planning` next week

## Notes

- **People options for daycare:** Andrew (parent), Lucy (parent), Gigi (grandma — watches Leo on Wednesdays at home)
- **People options for bedtime:** Andrew, Lucy, Both
- **Location logic:** Gigi → `@ Home`; anyone else → `@ Daycare`
- On Gigi days the morning action is "Pickup" (she picks Leo up from home) and the evening action is "Dropoff" (she drops him off at home). On daycare days the morning action is "Dropoff" and the evening action is "Pickup".
- Bedtime is every day of the week (7 days), not just weekdays.
- The bedtime schedule carries over week to week — always check last week first.
