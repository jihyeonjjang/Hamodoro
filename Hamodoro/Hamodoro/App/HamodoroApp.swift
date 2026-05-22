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
            Label(timerStore.statusText, systemImage: timerStore.isRunning ? "timer" : "timer.circle")
        }
        .menuBarExtraStyle(.window)

        Window("설정", id: HamodoroWindow.settings) {
            SettingsView(timerStore: timerStore, appSettingsStore: appSettingsStore)
        }
        .windowResizability(.contentSize)
    }
}
