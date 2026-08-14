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
            .onAppear {
                guard !appSettingsStore.hasCompletedOnboarding else { return }
                // As an LSUIElement (accessory, no Dock icon) app, macOS won't let a
                // window become key/focused at all — switch to .regular momentarily so
                // the onboarding window can actually appear. OnboardingView restores
                // .accessory once onboarding is dismissed.
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: HamodoroWindow.onboarding)
            }
    }
}
