# Today's Study Time — Design

**Date:** 2026-07-13
**Status:** Approved, ready for implementation planning

## Summary

Add a small, unobtrusive display of how much focus time the user has accumulated "today," shown in the idle screen of the menu bar popover. "Today" is defined by a custom 6 a.m.–to–6 a.m. boundary rather than midnight, matching how the user actually thinks about a study day.

## Placement

Shown as a small subtitle line directly under the "햄모도로" app title in `ProgressHeaderView`, visible **only in the idle state** — the same state where the title itself is shown. It disappears once a focus or break phase starts (same as the title).

This was chosen over three other placement options considered (always-visible line above the controls, a corner badge, or a dedicated Settings section) because it's the simplest change that satisfies "show today's total," and it doesn't compete for space with the timer UI while a session is active.

**Explicitly deferred:** a weekly/historical stats view (e.g., in the Settings window) was discussed as a possible future feature, but is **out of scope for this spec**. The data model below intentionally does not build toward it (see "Rejected alternative" below) — if/when a weekly view is scoped, it gets its own design pass.

## Data Model

Two new `UserDefaults` entries, following the existing `DefaultsKey` enum pattern already used in `PomodoroTimerStore` for `focusMinutes`/`breakMinutes`:

- `todayStudySeconds: Int` — accumulated focus seconds for the current study-day.
- `todayStudyDateKey: String` — the study-day key (`"yyyy-MM-dd"`, see below) that `todayStudySeconds` applies to.

No history of past days is stored. When a new study-day begins, the previous day's total is simply overwritten.

### Rejected alternative

A `[String: Int]` dictionary keyed by study-day (one entry per day, keeping full history) was considered, to make a future weekly total "additive" rather than requiring new storage later. This was rejected as premature: it solves a problem (weekly view) that hasn't been committed to yet, at the cost of extra code and an ever-growing (if small) stored history today. YAGNI — if the weekly view is built later, it starts accumulating history from that point forward, or gets its own storage design then.

## Study-Day Boundary (6 a.m.)

A day runs from 6 a.m. to the next 6 a.m., not midnight to midnight. Add a pure function to `PomodoroTimerStore`:

```swift
private func studyDayKey(for date: Date) -> String {
    var calendar = Calendar.current
    calendar.timeZone = .current
    let hour = calendar.component(.hour, from: date)
    let effectiveDate = hour < 6 ? calendar.date(byAdding: .day, value: -1, to: date)! : date
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: effectiveDate)
}
```

Taking `Date` as a parameter (rather than reading `Date()` internally) makes the boundary testable with fixed timestamps, matching the existing convention in `formattedClockTime(_ date: Date)`.

## Counting Rule

Focus time only counts; break time does not.

In `tick()`, when `phase == .focus` and a second elapses:

1. Compute `currentKey = studyDayKey(for: Date())`.
2. If `currentKey != todayStudyDateKey` (the study-day has rolled over since the last tick, or this is the first tick after a stale/missing key): set `todayStudySeconds = 0` and `todayStudyDateKey = currentKey`.
3. Increment `todayStudySeconds` by 1.
4. Persist both values to `UserDefaults` immediately (same immediate-write pattern as `updateFocusMinutes`/`updateBreakMinutes` — no batching), so no progress is lost if the app is quit mid-session.

## Startup Behavior

On `PomodoroTimerStore.init()`:

- Read persisted `todayStudySeconds` and `todayStudyDateKey`.
- If `todayStudyDateKey == studyDayKey(for: Date())`, restore `todayStudySeconds` as-is.
- Otherwise (stale key from a previous study-day, or no key yet), start at 0. No explicit clear is needed — the next `tick()` will overwrite the stale value per the counting rule above.

## Display

New computed property, e.g. `todayStudyTimeText: String?` on `PomodoroTimerStore`:

- Returns `nil` when `todayStudySeconds == 0` — `ProgressHeaderView` hides the line entirely in this case, keeping the idle screen exactly as clean as it is today until the first focus second accumulates.
- Otherwise formats as Korean text: `"H시간 M분 집중했어요"`, omitting the hours component when under an hour (e.g. `"30분 집중했어요"`, not `"0시간 30분 집중했어요"`).
- Minutes are floored (`todayStudySeconds / 60`), not rounded up — an elapsed/accumulated total shouldn't claim credit for a minute that hasn't fully completed yet (unlike `remainingMinutes`, which ceils because it's counting down).

## Testing

Unit tests in `HamodoroTests.swift`:

1. `studyDayKey(for:)` returns the previous calendar day for a 05:59 timestamp, and the current calendar day for a 06:00 timestamp.
2. `tick()` during `.focus` increments `todayStudySeconds`; `tick()` during `.breakTime` does not.
3. A fresh `PomodoroTimerStore` instance restores a persisted `todayStudySeconds` when the stored date key matches the current study-day.
4. A fresh `PomodoroTimerStore` instance does **not** restore a persisted value when the stored date key belongs to a previous study-day (rollover correctness on relaunch).

## Out of Scope

- Weekly, monthly, or all-time totals.
- Any history of past days.
- A stats section in the Settings window.
- Pruning/cleanup logic (moot, since no history is kept).
