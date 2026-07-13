//
//  HamodoroTests.swift
//  HamodoroTests
//
//  Created by 지현 on 5/11/26.
//

import XCTest
@testable import Hamodoro

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

}
