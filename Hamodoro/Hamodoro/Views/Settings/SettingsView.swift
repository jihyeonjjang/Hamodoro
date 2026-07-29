//
//  SettingsView.swift
//  Hamodoro
//
//  Created by 지현 on 5/13/26.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var timerStore: PomodoroTimerStore
    @ObservedObject var appSettingsStore: AppSettingsStore

    var body: some View {
        Form {
            Section("시간") {
                durationPicker(
                    title: "집중",
                    minutes: focusMinutesBinding,
                    options: PomodoroTimerStore.focusMinuteOptions
                )

                durationPicker(
                    title: "휴식",
                    minutes: breakMinutesBinding,
                    options: PomodoroTimerStore.breakMinuteOptions
                )
            }

            Section("알림") {
                Toggle("집중 시작 알림", isOn: focusStartNotificationBinding)
                Toggle("휴식 시작 알림", isOn: breakStartNotificationBinding)
            }

            Section("자동 실행") {
                Toggle("로그인 시 햄모도로를 자동 실행", isOn: launchAtLoginBinding)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(minWidth: 340, maxWidth: 420)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private var focusMinutesBinding: Binding<Int> {
        Binding(
            get: { timerStore.focusMinutes },
            set: { timerStore.updateFocusMinutes($0) }
        )
    }

    private var breakMinutesBinding: Binding<Int> {
        Binding(
            get: { timerStore.breakMinutes },
            set: { timerStore.updateBreakMinutes($0) }
        )
    }

    private var focusStartNotificationBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.focusStartNotificationEnabled },
            set: { appSettingsStore.updateFocusStartNotificationEnabled($0) }
        )
    }

    private var breakStartNotificationBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.breakStartNotificationEnabled },
            set: { appSettingsStore.updateBreakStartNotificationEnabled($0) }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.launchAtLoginEnabled },
            set: { appSettingsStore.updateLaunchAtLoginEnabled($0) }
        )
    }

    private func durationPicker(title: String, minutes: Binding<Int>, options: [Int]) -> some View {
        Picker(title, selection: minutes) {
            ForEach(options, id: \.self) { minute in
                Text("\(minute)분")
                    .tag(minute)
            }
        }
        .pickerStyle(.menu)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(timerStore: PomodoroTimerStore(), appSettingsStore: AppSettingsStore())
    }
}
