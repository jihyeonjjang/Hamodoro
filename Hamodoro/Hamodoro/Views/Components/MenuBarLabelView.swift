//
//  MenuBarLabelView.swift
//  Hamodoro
//

import SwiftUI
import AppKit

struct MenuBarLabelView: View {
    let phase: PomodoroTimerStore.Phase
    let isRunning: Bool
    @ObservedObject var appSettingsStore: AppSettingsStore

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        MenuBarIconView(phase: phase, isRunning: isRunning)
            .task {
                guard !appSettingsStore.hasCompletedOnboarding else { return }
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: HamodoroWindow.onboarding)
            }
    }
}
