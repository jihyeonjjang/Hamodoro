//
//  TimerNotificationManager.swift
//  Hamodoro
//
//  Created by 지현 on 5/13/26.
//

import Foundation
import UserNotifications

@MainActor
final class TimerNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = TimerNotificationManager()

    private let center = UNUserNotificationCenter.current()

    func configure() {
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error {
                NSLog("Failed to request notification authorization: \(error)")
            }
        }
    }

    func notifyPhaseEnded(_ phase: PomodoroTimerStore.Phase) {
        let content = UNMutableNotificationContent()
        content.sound = .default

        switch phase {
        case .idle:
            return
        case .focus:
            guard AppSettingsStore.isBreakStartNotificationEnabled else { return }

            content.title = "집중 완료"
            content.body = "이제 휴식이다햄!"
        case .breakTime:
            guard AppSettingsStore.isFocusStartNotificationEnabled else { return }

            content.title = "휴식 완료"
            content.body = "이제 집중이다햄..."
        }

        let request = UNNotificationRequest(
            identifier: "hamodoro-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request) { error in
            if let error {
                NSLog("Failed to add notification request: \(error)")
            }
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
