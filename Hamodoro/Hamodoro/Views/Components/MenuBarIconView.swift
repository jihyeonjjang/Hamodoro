//
//  MenuBarIconView.swift
//  Hamodoro
//

import Combine
import SwiftUI

struct MenuBarIconView: View {
    let phase: PomodoroTimerStore.Phase
    let isRunning: Bool

    @State private var frameIndex = 0
    @State private var elapsed: TimeInterval = 0

    private static let focusFrames = ["menuBarRun1", "menuBarRun2", "menuBarRun3", "menuBarRun4"]
    private static let breakFrames = ["menuBarBreak1", "menuBarBreak2", "menuBarBreak3", "menuBarBreak4"]
    private static let focusFrameInterval: TimeInterval = 0.1
    private static let breakFrameInterval: TimeInterval = 0.35
    private static let tickInterval: TimeInterval = 0.05
    private let timer = Timer.publish(every: tickInterval, on: .main, in: .common).autoconnect()

    private var runFrames: [String] {
        phase == .breakTime ? Self.breakFrames : Self.focusFrames
    }

    private var frameInterval: TimeInterval {
        phase == .breakTime ? Self.breakFrameInterval : Self.focusFrameInterval
    }

    var body: some View {
        Group {
            if phase == .idle {
                Image("menuBarIdle")
                    .renderingMode(.template)
            } else if !isRunning {
                Image("menuBarPaused")
                    .renderingMode(.template)
            } else {
                Image(runFrames[frameIndex])
                    .renderingMode(.template)
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            elapsed += Self.tickInterval
            guard elapsed >= frameInterval else { return }
            elapsed = 0
            frameIndex = (frameIndex + 1) % runFrames.count
        }
        .onChange(of: isRunning) { _, newValue in
            if !newValue {
                frameIndex = 0
                elapsed = 0
            }
        }
        .onChange(of: phase) { _, _ in
            frameIndex = 0
            elapsed = 0
        }
    }
}
