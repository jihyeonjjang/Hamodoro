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
                // Don't call NSApp.activate here — for a brand-new window this races
                // window creation and can drop the openWindow request entirely on an
                // LSUIElement (accessory) app. OnboardingView.onAppear activates once
                // the window actually exists, matching the SettingsButton pattern.
                openWindow(id: HamodoroWindow.onboarding)
            }
    }
}
