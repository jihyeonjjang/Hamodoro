//
//  HamodoroApp.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

@main
struct HamodoroApp: App {
    @StateObject private var timerStore = PomodoroTimerStore()
    @StateObject private var appSettingsStore = AppSettingsStore()

    init() {
        TimerNotificationManager.shared.configure()
    }

    var body: some Scene {
        MenuBarExtra {
            HamodoroRootView(timerStore: timerStore)
        } label: {
            MenuBarLabelView(
                phase: timerStore.phase,
                isRunning: timerStore.isRunning,
                appSettingsStore: appSettingsStore
            )
        }
        .menuBarExtraStyle(.window)

        Window("설정", id: HamodoroWindow.settings) {
            SettingsView(timerStore: timerStore, appSettingsStore: appSettingsStore)
        }
        .windowResizability(.contentSize)

        Window("햄모도로 시작하기", id: HamodoroWindow.onboarding) {
            OnboardingView(appSettingsStore: appSettingsStore)
        }
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
    }
}
