# Today's Study Time Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a small "N시간 M분 집중했어요" line under the app title on the idle screen, tracking focus time accumulated since the last 6 a.m. boundary, persisted across app relaunches.

**Architecture:** All new logic lives in `PomodoroTimerStore` (existing single source of timer truth), following its established `UserDefaults`-backed persistence pattern. `ProgressHeaderView` only reads one new computed property and renders it conditionally — no new files.

**Tech Stack:** Swift, SwiftUI, XCTest, `UserDefaults`. No new dependencies.

## Global Constraints

- `PomodoroTimerStore` is `final class ... @MainActor` — any test that constructs an instance or calls its instance methods must run in a `@MainActor`-isolated context. (Source: `Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift:12`)
- Persist new state via the existing `private enum DefaultsKey { static let ... }` pattern and `UserDefaults.standard.set(...)` — write immediately, no batching (matches `updateFocusMinutes`/`updateBreakMinutes`).
- Date formatting uses `Locale(identifier: "ko_KR")`, matching the existing `formattedClockTime(_:)` helper.
- The study day runs from 6 a.m. to the next 6 a.m., not midnight to midnight.
- No history of past days is stored or displayed — single current-day value only. (Spec: `docs/superpowers/specs/2026-07-13-today-study-time-design.md`, "Rejected alternative")
- Minutes in the display text are floored (`seconds / 60`), never rounded up.
- The subtitle line is hidden entirely (not shown as "0분") when zero seconds have been studied today.

---

### Task 1: Study-day boundary key function

**Files:**
- Modify: `Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift:249-254` (insert new function directly after `formattedClockTime`)
- Test: `Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift`

**Interfaces:**
- Consumes: nothing new.
- Produces: `nonisolated static func studyDayKey(for date: Date) -> String` — returns a `"yyyy-MM-dd"` string representing which study-day `date` falls into, where a day runs 6 a.m.–6 a.m. Later tasks call this as `Self.studyDayKey(for: Date())` from both `init()` and instance methods, and tests call it as `PomodoroTimerStore.studyDayKey(for:)`.

- [ ] **Step 1: Write the failing tests**

Add to `HamodoroTests.swift`, replacing the file's contents with:

```swift
//
//  HamodoroTests.swift
//  HamodoroTests
//
//  Created by 지현 on 5/11/26.
//

import XCTest
@testable import Hamodoro

final class HamodoroTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testStudyDayKeyBeforeSixAMBelongsToPreviousDay() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 13
        components.hour = 5
        components.minute = 59
        let date = Calendar.current.date(from: components)!

        let key = PomodoroTimerStore.studyDayKey(for: date)

        XCTAssertEqual(key, "2026-07-12")
    }

    func testStudyDayKeyAtSixAMBelongsToCurrentDay() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 13
        components.hour = 6
        components.minute = 0
        let date = Calendar.current.date(from: components)!

        let key = PomodoroTimerStore.studyDayKey(for: date)

        XCTAssertEqual(key, "2026-07-13")
    }

}
```

- [ ] **Step 2: Run tests to verify the new ones fail**

Run from `Hamodoro/Hamodoro/`:

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **BUILD FAILED** — `studyDayKey` is not a member of `PomodoroTimerStore`.

- [ ] **Step 3: Implement `studyDayKey`**

In `PomodoroTimerStore.swift`, the current tail of the file reads:

```swift
    private func formattedClockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: date)
    }
}
```

Change it to:

```swift
    private func formattedClockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: date)
    }

    nonisolated static func studyDayKey(for date: Date) -> String {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let hour = calendar.component(.hour, from: date)
        let effectiveDate = hour < 6 ? calendar.date(byAdding: .day, value: -1, to: date)! : date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: effectiveDate)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **TEST SUCCEEDED**, all tests including `testStudyDayKeyBeforeSixAMBelongsToPreviousDay` and `testStudyDayKeyAtSixAMBelongsToCurrentDay` pass.

- [ ] **Step 5: Commit**

```bash
git add Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift
git commit -m "Add study-day boundary key function"
```

---

### Task 2: Today's study-seconds persistence and startup restore

**Files:**
- Modify: `Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift:11-16` (class declaration + `DefaultsKey`)
- Modify: `Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift:39-58` (published properties + `init()`)
- Test: `Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift`

**Interfaces:**
- Consumes: `PomodoroTimerStore.studyDayKey(for:) -> String` (Task 1).
- Produces: `@Published private(set) var todayStudySeconds: Int` — read by Task 3 (counting) and Task 4 (display formatting). Two new `UserDefaults` keys: `DefaultsKey.todayStudySeconds` (`"todayStudySeconds"`), `DefaultsKey.todayStudyDateKey` (`"todayStudyDateKey"`) — read/written by Task 3.

- [ ] **Step 1: Write the failing tests**

Add to `HamodoroTests.swift`. First, change the class declaration and add cleanup so these tests don't leak state into each other:

```swift
@MainActor
final class HamodoroTests: XCTestCase {

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: "todayStudySeconds")
        UserDefaults.standard.removeObject(forKey: "todayStudyDateKey")
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "todayStudySeconds")
        UserDefaults.standard.removeObject(forKey: "todayStudyDateKey")
    }
```

Then add these two tests (anywhere inside the class body):

```swift
    func testInitRestoresTodayStudySecondsWhenDateKeyMatchesCurrentStudyDay() throws {
        let currentKey = PomodoroTimerStore.studyDayKey(for: Date())
        UserDefaults.standard.set(currentKey, forKey: "todayStudyDateKey")
        UserDefaults.standard.set(125, forKey: "todayStudySeconds")

        let store = PomodoroTimerStore()

        XCTAssertEqual(store.todayStudySeconds, 125)
    }

    func testInitDiscardsTodayStudySecondsWhenDateKeyIsStale() throws {
        UserDefaults.standard.set("2000-01-01", forKey: "todayStudyDateKey")
        UserDefaults.standard.set(999, forKey: "todayStudySeconds")

        let store = PomodoroTimerStore()

        XCTAssertEqual(store.todayStudySeconds, 0)
    }
```

- [ ] **Step 2: Run tests to verify the new ones fail**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **BUILD FAILED** — `todayStudySeconds` is not a member of `PomodoroTimerStore`.

- [ ] **Step 3: Implement the property, keys, and restore logic**

In `PomodoroTimerStore.swift`, change:

```swift
@MainActor
final class PomodoroTimerStore: ObservableObject {
    private enum DefaultsKey {
        static let focusMinutes = "focusMinutes"
        static let breakMinutes = "breakMinutes"
    }
```

to:

```swift
@MainActor
final class PomodoroTimerStore: ObservableObject {
    private enum DefaultsKey {
        static let focusMinutes = "focusMinutes"
        static let breakMinutes = "breakMinutes"
        static let todayStudySeconds = "todayStudySeconds"
        static let todayStudyDateKey = "todayStudyDateKey"
    }
```

Change:

```swift
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var isRunning = false
    @Published private(set) var focusMinutes: Double
    @Published private(set) var breakMinutes: Double
    @Published var selectedCycleCount = 1
```

to:

```swift
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var isRunning = false
    @Published private(set) var focusMinutes: Double
    @Published private(set) var breakMinutes: Double
    @Published private(set) var todayStudySeconds: Int
    @Published var selectedCycleCount = 1
```

Change:

```swift
    init() {
        let savedFocusMinutes = UserDefaults.standard.double(forKey: DefaultsKey.focusMinutes)
        let savedBreakMinutes = UserDefaults.standard.double(forKey: DefaultsKey.breakMinutes)
        let initialFocusMinutes = Self.nearestOption(to: savedFocusMinutes > 0 ? savedFocusMinutes : 25, in: Self.focusMinuteOptions)
        let initialBreakMinutes = Self.nearestOption(to: savedBreakMinutes > 0 ? savedBreakMinutes : 5, in: Self.breakMinuteOptions)
        self.focusMinutes = initialFocusMinutes
        self.breakMinutes = initialBreakMinutes
        self.remainingSeconds = Int(initialFocusMinutes * 60)
    }
```

to:

```swift
    init() {
        let savedFocusMinutes = UserDefaults.standard.double(forKey: DefaultsKey.focusMinutes)
        let savedBreakMinutes = UserDefaults.standard.double(forKey: DefaultsKey.breakMinutes)
        let initialFocusMinutes = Self.nearestOption(to: savedFocusMinutes > 0 ? savedFocusMinutes : 25, in: Self.focusMinuteOptions)
        let initialBreakMinutes = Self.nearestOption(to: savedBreakMinutes > 0 ? savedBreakMinutes : 5, in: Self.breakMinuteOptions)
        self.focusMinutes = initialFocusMinutes
        self.breakMinutes = initialBreakMinutes
        self.remainingSeconds = Int(initialFocusMinutes * 60)

        let currentStudyDayKey = Self.studyDayKey(for: Date())
        let storedStudyDateKey = UserDefaults.standard.string(forKey: DefaultsKey.todayStudyDateKey)
        self.todayStudySeconds = storedStudyDateKey == currentStudyDayKey
            ? UserDefaults.standard.integer(forKey: DefaultsKey.todayStudySeconds)
            : 0
    }
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **TEST SUCCEEDED**, all tests pass.

- [ ] **Step 5: Commit**

```bash
git add Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift
git commit -m "Add today's study time persistence and startup restore"
```

---

### Task 3: Wire live counting into tick()

**Files:**
- Modify: `Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift:205-213` (`tick()`)
- Test: `Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift`

**Interfaces:**
- Consumes: `todayStudySeconds` property and `DefaultsKey.todayStudySeconds`/`DefaultsKey.todayStudyDateKey` (Task 2), `Self.studyDayKey(for:)` (Task 1).
- Produces: `tick()` becomes non-`private` (internal) so tests can call it directly without a real `Timer` firing. No new public API beyond that — later tasks don't depend on anything new from this task.

- [ ] **Step 1: Write the failing tests**

Add to `HamodoroTests.swift`:

```swift
    func testTickIncrementsTodayStudySecondsDuringFocus() throws {
        let store = PomodoroTimerStore()
        store.updateFocusMinutes(25)
        store.startFocus()

        store.tick()
        store.tick()
        store.pause()

        XCTAssertEqual(store.todayStudySeconds, 2)
    }

    func testTickDoesNotIncrementTodayStudySecondsDuringBreak() throws {
        let store = PomodoroTimerStore()
        store.updateBreakMinutes(5)
        store.startBreak()

        store.tick()
        store.pause()

        XCTAssertEqual(store.todayStudySeconds, 0)
    }
```

(`updateFocusMinutes`/`updateBreakMinutes` are called explicitly so these tests don't depend on whatever focus/break duration happens to be saved in `UserDefaults` from real app usage — otherwise a very short saved duration could make the phase advance mid-test.)

- [ ] **Step 2: Run tests to verify the new ones fail**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **BUILD FAILED** — `tick()` is inaccessible due to `private` protection level.

- [ ] **Step 3: Implement the counting logic**

In `PomodoroTimerStore.swift`, change:

```swift
    private func tick() {
        guard isRunning else { return }

        if remainingSeconds > 1 {
            remainingSeconds -= 1
        } else {
            moveToNextPhase()
        }
    }
```

to:

```swift
    func tick() {
        guard isRunning else { return }

        if phase == .focus {
            recordFocusSecond()
        }

        if remainingSeconds > 1 {
            remainingSeconds -= 1
        } else {
            moveToNextPhase()
        }
    }

    private func recordFocusSecond() {
        let currentKey = Self.studyDayKey(for: Date())
        if currentKey != UserDefaults.standard.string(forKey: DefaultsKey.todayStudyDateKey) {
            todayStudySeconds = 0
            UserDefaults.standard.set(currentKey, forKey: DefaultsKey.todayStudyDateKey)
        }
        todayStudySeconds += 1
        UserDefaults.standard.set(todayStudySeconds, forKey: DefaultsKey.todayStudySeconds)
    }
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **TEST SUCCEEDED**, all tests pass.

- [ ] **Step 5: Commit**

```bash
git add Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift
git commit -m "Wire today's study time counting into tick()"
```

---

### Task 4: Display formatting

**Files:**
- Modify: `Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift:68-70` (insert after `remainingTimeText`)
- Test: `Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift`

**Interfaces:**
- Consumes: `todayStudySeconds` (Task 2).
- Produces: `var todayStudyTimeText: String?` — read by Task 5 in `ProgressHeaderView`. `nil` when `todayStudySeconds == 0`; otherwise Korean text `"H시간 M분 집중했어요"` (hours omitted when 0).

- [ ] **Step 1: Write the failing tests**

Add to `HamodoroTests.swift`:

```swift
    func testTodayStudyTimeTextIsNilWhenNoTimeStudiedToday() throws {
        let store = PomodoroTimerStore()

        XCTAssertNil(store.todayStudyTimeText)
    }

    func testTodayStudyTimeTextOmitsHoursUnderOneHour() throws {
        let currentKey = PomodoroTimerStore.studyDayKey(for: Date())
        UserDefaults.standard.set(currentKey, forKey: "todayStudyDateKey")
        UserDefaults.standard.set(125, forKey: "todayStudySeconds")

        let store = PomodoroTimerStore()

        XCTAssertEqual(store.todayStudyTimeText, "2분 집중했어요")
    }

    func testTodayStudyTimeTextIncludesHoursOverOneHour() throws {
        let currentKey = PomodoroTimerStore.studyDayKey(for: Date())
        UserDefaults.standard.set(currentKey, forKey: "todayStudyDateKey")
        UserDefaults.standard.set(3725, forKey: "todayStudySeconds")

        let store = PomodoroTimerStore()

        XCTAssertEqual(store.todayStudyTimeText, "1시간 2분 집중했어요")
    }
```

- [ ] **Step 2: Run tests to verify the new ones fail**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **BUILD FAILED** — `todayStudyTimeText` is not a member of `PomodoroTimerStore`.

- [ ] **Step 3: Implement the formatter**

In `PomodoroTimerStore.swift`, change:

```swift
    var remainingTimeText: String {
        formattedTime(remainingSeconds)
    }

    var remainingMinutes: Int {
```

to:

```swift
    var remainingTimeText: String {
        formattedTime(remainingSeconds)
    }

    var todayStudyTimeText: String? {
        guard todayStudySeconds > 0 else { return nil }

        let totalMinutes = todayStudySeconds / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)시간 \(minutes)분 집중했어요"
        } else {
            return "\(minutes)분 집중했어요"
        }
    }

    var remainingMinutes: Int {
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Hamodoro.xcodeproj -scheme Hamodoro -only-testing:HamodoroTests -destination 'platform=macOS'
```

Expected: **TEST SUCCEEDED**, all tests pass.

- [ ] **Step 5: Commit**

```bash
git add Hamodoro/Hamodoro/Store/PomodoroTimerStore.swift Hamodoro/Hamodoro/HamodoroTests/HamodoroTests.swift
git commit -m "Add today's study time display formatting"
```

---

### Task 5: Show it in the idle screen

**Files:**
- Modify: `Hamodoro/Hamodoro/Views/Timer/ProgressHeaderView.swift:14-21`

**Interfaces:**
- Consumes: `timerStore.todayStudyTimeText: String?` (Task 4).
- Produces: nothing consumed by later tasks — this is the last task.

- [ ] **Step 1: Update the idle-state view**

In `ProgressHeaderView.swift`, change:

```swift
        ZStack {
            // Idle state: Show app title
            if timerStore.phase == .idle {
                Text("햄모도로")
                    .font(.hakgyoansimKkokkomaRegular(size: 36))
                    .foregroundStyle(HamodoroDesign.Color.primaryText)
                    .padding(.top, 24)
            }
```

to:

```swift
        ZStack {
            // Idle state: Show app title
            if timerStore.phase == .idle {
                VStack(spacing: 4) {
                    Text("햄모도로")
                        .font(.hakgyoansimKkokkomaRegular(size: 36))
                        .foregroundStyle(HamodoroDesign.Color.primaryText)

                    if let todayStudyTimeText = timerStore.todayStudyTimeText {
                        Text(todayStudyTimeText)
                            .font(.hakgyoansimKkokkomaRegular(size: 13))
                            .foregroundStyle(HamodoroDesign.Color.secondaryText)
                    }
                }
                .padding(.top, 24)
            }
```

- [ ] **Step 2: Build to verify it compiles**

From `Hamodoro/Hamodoro/`:

```bash
xcodebuild build -project Hamodoro.xcodeproj -scheme Hamodoro -destination 'platform=macOS'
```

Expected: **BUILD SUCCEEDED**.

- [ ] **Step 3: Manually verify in the running app**

There is no automated UI test infrastructure in this project (`HamodoroUITests.swift` is unmodified Xcode boilerplate) — verify visually:

1. Launch the app (⌘R in Xcode, or run the built `.app`).
2. Idle screen should show just "햄모도로" with no subtitle (fresh install / today's total is 0).
3. Start a focus session, let a few seconds pass, then return home (stop button) so it's idle again.
4. Idle screen should now show "햄모도로" with a small "N분 집중했어요" line underneath.
5. Quit and relaunch the app — the subtitle should still show the same total (persistence check).

- [ ] **Step 4: Commit**

```bash
git add Hamodoro/Hamodoro/Views/Timer/ProgressHeaderView.swift
git commit -m "Show today's study time in idle screen"
```
