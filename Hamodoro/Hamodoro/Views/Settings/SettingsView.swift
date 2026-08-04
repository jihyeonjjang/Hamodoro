//
//  SettingsView.swift
//  Hamodoro
//
//  Created by 지현 on 5/13/26.
//

import SwiftUI
import AppKit
import UserNotifications

struct SettingsView: View {
    @ObservedObject var timerStore: PomodoroTimerStore
    @ObservedObject var appSettingsStore: AppSettingsStore

    @State private var showSystemDeniedAlert = false
    @State private var pendingDisableKind: NotificationKind?

    private enum NotificationKind {
        case focus
        case breakTime

        var confirmTitle: String {
            switch self {
            case .focus:
                return "공부 알림을 받아볼 수 없어요"
            case .breakTime:
                return "휴식 알림을 받아볼 수 없어요"
            }
        }

        var confirmMessage: String {
            switch self {
            case .focus:
                return "지금 끄면 휴식이 끝나도 집중을 시작하라는 알림을 받을 수 없어요."
            case .breakTime:
                return "지금 끄면 집중이 끝나도 휴식을 시작하라는 알림을 받을 수 없어요."
            }
        }
    }

    var body: some View {
        Form {
            Section("시간") {
                durationPicker(
                    title: "집중",
                    minutes: focusMinutesBinding,
                    options: PomodoroTimerStore.focusMinuteOptions
                )
                .disabled(timerStore.phase == .focus)

                durationPicker(
                    title: "휴식",
                    minutes: breakMinutesBinding,
                    options: PomodoroTimerStore.breakMinuteOptions
                )
                .disabled(timerStore.phase == .breakTime)
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
        .task {
            let status = await TimerNotificationManager.shared.currentAuthorizationStatus()
            showSystemDeniedAlert = (status == .denied)
        }
        .alert("알림을 받을 수 없어요", isPresented: $showSystemDeniedAlert) {
            Button("설정으로 이동") { openSystemNotificationSettings() }
            Button("닫기", role: .cancel) {}
        } message: {
            Text("시스템 알림이 꺼져 있어 공부/휴식 알림을 받아볼 수 없어요. 설정에서 알림을 허용해 주세요.")
        }
        .alert(
            pendingDisableKind?.confirmTitle ?? "",
            isPresented: Binding(
                get: { pendingDisableKind != nil },
                set: { isPresented in
                    if !isPresented { pendingDisableKind = nil }
                }
            )
        ) {
            Button("끄기", role: .destructive) { confirmDisable() }
            Button("유지하기", role: .cancel) { pendingDisableKind = nil }
        } message: {
            Text(pendingDisableKind?.confirmMessage ?? "")
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
            set: { handleNotificationToggle($0, kind: .focus) }
        )
    }

    private var breakStartNotificationBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.breakStartNotificationEnabled },
            set: { handleNotificationToggle($0, kind: .breakTime) }
        )
    }

    private func handleNotificationToggle(_ newValue: Bool, kind: NotificationKind) {
        guard !newValue else {
            apply(true, kind: kind)
            return
        }

        Task {
            let status = await TimerNotificationManager.shared.currentAuthorizationStatus()
            if TimerNotificationManager.isAuthorizationGranted(status) {
                pendingDisableKind = kind
            } else {
                apply(false, kind: kind)
            }
        }
    }

    private func confirmDisable() {
        guard let kind = pendingDisableKind else { return }
        apply(false, kind: kind)
        pendingDisableKind = nil
    }

    private func apply(_ isEnabled: Bool, kind: NotificationKind) {
        switch kind {
        case .focus:
            appSettingsStore.updateFocusStartNotificationEnabled(isEnabled)
        case .breakTime:
            appSettingsStore.updateBreakStartNotificationEnabled(isEnabled)
        }
    }

    private func openSystemNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
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
