//
//  PomodoroTimerStore.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import Combine
import Foundation

@MainActor
final class PomodoroTimerStore: ObservableObject {
    private enum DefaultsKey {
        static let focusMinutes = "focusMinutes"
        static let breakMinutes = "breakMinutes"
    }

    static let focusMinuteOptions = Array(stride(from: 5, through: 60, by: 5))
    static let breakMinuteOptions = [1, 3, 5, 10, 15, 20, 30]

    enum Phase {
        case idle
        case focus
        case breakTime

        var title: String {
            switch self {
            case .idle:
                return "Idle"
            case .focus:
                return "Focus"
            case .breakTime:
                return "Break"
            }
        }
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var isRunning = false
    @Published private(set) var focusMinutes: Int
    @Published private(set) var breakMinutes: Int
    @Published var selectedCycleCount = 1

    private var timer: Timer?
    private var plannedPhases: [Phase] = []
    private var currentPhaseIndex = 0

    init() {
        let savedFocusMinutes = UserDefaults.standard.integer(forKey: DefaultsKey.focusMinutes)
        let savedBreakMinutes = UserDefaults.standard.integer(forKey: DefaultsKey.breakMinutes)
        let initialFocusMinutes = Self.nearestOption(to: savedFocusMinutes > 0 ? savedFocusMinutes : 25, in: Self.focusMinuteOptions)
        let initialBreakMinutes = Self.nearestOption(to: savedBreakMinutes > 0 ? savedBreakMinutes : 5, in: Self.breakMinuteOptions)
        self.focusMinutes = initialFocusMinutes
        self.breakMinutes = initialBreakMinutes
        self.remainingSeconds = initialFocusMinutes * 60
    }

    var statusText: String {
        "\(phase.title) \(remainingTimeText)"
    }

    var totalSessionTimeText: String {
        formattedTime(currentDuration)
    }

    var remainingTimeText: String {
        formattedTime(remainingSeconds)
    }

    var remainingMinutes: Int {
        Int(ceil(Double(remainingSeconds) / 60.0))
    }

    var remainingProgress: Double {
        guard phase != .idle, currentDuration > 0 else { return 0 }
        return Double(remainingSeconds) / Double(currentDuration)
    }

    var focusFirstEndClockText: String {
        endClockText(for: makeFocusFirstSequence())
    }

    func start() {
        if phase == .idle {
            startFocus()
            return
        }

        guard !isRunning else { return }

        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        timer?.tolerance = 0.1
    }

    func startFocus() {
        beginSequence(makeFocusFirstSequence())
    }

    func startBreak() {
        beginSequence(makeBreakFirstSequence())
    }

    func updateFocusMinutes(_ minutes: Int) {
        focusMinutes = Self.nearestOption(to: minutes, in: Self.focusMinuteOptions)
        UserDefaults.standard.set(focusMinutes, forKey: DefaultsKey.focusMinutes)

        if phase == .idle {
            remainingSeconds = focusDuration
        }
    }

    func updateBreakMinutes(_ minutes: Int) {
        breakMinutes = Self.nearestOption(to: minutes, in: Self.breakMinuteOptions)
        UserDefaults.standard.set(breakMinutes, forKey: DefaultsKey.breakMinutes)

        if phase == .breakTime, !isRunning {
            remainingSeconds = min(remainingSeconds, breakDuration)
        }
    }

    func togglePause() {
        isRunning ? pause() : start()
    }

    func pause() {
        isRunning = false
        stopTimer()
    }

    func reset() {
        pause()
        remainingSeconds = currentDuration
    }

    func returnHome() {
        pause()
        plannedPhases = []
        currentPhaseIndex = 0
        phase = .idle
        remainingSeconds = focusDuration
    }

    private var currentDuration: Int {
        switch phase {
        case .idle, .focus:
            return focusDuration
        case .breakTime:
            return breakDuration
        }
    }

    private var focusDuration: Int {
        focusMinutes * 60
    }

    private var breakDuration: Int {
        breakMinutes * 60
    }

    private func beginSequence(_ phases: [Phase]) {
        guard let firstPhase = phases.first else { return }

        pause()
        plannedPhases = phases
        currentPhaseIndex = 0
        phase = firstPhase
        remainingSeconds = currentDuration
        start()
    }

    private func makeFocusFirstSequence() -> [Phase] {
        Array(repeating: [.focus, .breakTime], count: selectedCycleCount).flatMap { $0 }
    }

    private func makeBreakFirstSequence() -> [Phase] {
        [.breakTime] + makeFocusFirstSequence()
    }

    private func endClockText(for phases: [Phase]) -> String {
        let totalSeconds = phases.reduce(0) { partialResult, phase in
            partialResult + duration(for: phase)
        }
        let endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        return formattedClockTime(endDate)
    }

    private func duration(for phase: Phase) -> Int {
        switch phase {
        case .idle:
            return 0
        case .focus:
            return focusDuration
        case .breakTime:
            return breakDuration
        }
    }

    private func tick() {
        guard isRunning else { return }

        if remainingSeconds > 1 {
            remainingSeconds -= 1
        } else {
            moveToNextPhase()
        }
    }

    private func moveToNextPhase() {
        if currentPhaseIndex + 1 < plannedPhases.count {
            currentPhaseIndex += 1
            phase = plannedPhases[currentPhaseIndex]
            remainingSeconds = currentDuration
        } else {
            returnHome()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private static func nearestOption(to minutes: Int, in options: [Int]) -> Int {
        options.min { first, second in
            abs(first - minutes) < abs(second - minutes)
        } ?? minutes
    }

    deinit {
        timer?.invalidate()
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formattedClockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: date)
    }
}
