//
//  AppSettingsStore.swift
//  Hamodoro
//
//  Created by 지현 on 5/13/26.
//

import Foundation
import Combine
import ServiceManagement

@MainActor
final class AppSettingsStore: ObservableObject {
    private enum DefaultsKey {
        static let focusStartNotificationEnabled = "focusStartNotificationEnabled"
        static let breakStartNotificationEnabled = "breakStartNotificationEnabled"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    @Published private(set) var launchAtLoginEnabled: Bool
    @Published private(set) var focusStartNotificationEnabled: Bool
    @Published private(set) var breakStartNotificationEnabled: Bool
    @Published private(set) var hasCompletedOnboarding: Bool

    init() {
        self.launchAtLoginEnabled = Self.isLaunchAtLoginEnabled
        self.focusStartNotificationEnabled = Self.isFocusStartNotificationEnabled
        self.breakStartNotificationEnabled = Self.isBreakStartNotificationEnabled
        self.hasCompletedOnboarding = Self.isOnboardingCompleted
    }

    static var isFocusStartNotificationEnabled: Bool {
        bool(forKey: DefaultsKey.focusStartNotificationEnabled, defaultValue: true)
    }

    static var isBreakStartNotificationEnabled: Bool {
        bool(forKey: DefaultsKey.breakStartNotificationEnabled, defaultValue: true)
    }

    static var isOnboardingCompleted: Bool {
        bool(forKey: DefaultsKey.hasCompletedOnboarding, defaultValue: false)
    }

    func updateFocusStartNotificationEnabled(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: DefaultsKey.focusStartNotificationEnabled)
        focusStartNotificationEnabled = isEnabled
    }

    func updateBreakStartNotificationEnabled(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: DefaultsKey.breakStartNotificationEnabled)
        breakStartNotificationEnabled = isEnabled
    }

    func updateLaunchAtLoginEnabled(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Failed to update launch at login setting: \(error)")
        }

        launchAtLoginEnabled = Self.isLaunchAtLoginEnabled
    }

    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: DefaultsKey.hasCompletedOnboarding)
        hasCompletedOnboarding = true
    }

    private static var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    private static func bool(forKey key: String, defaultValue: Bool) -> Bool {
        let defaults = UserDefaults.standard

        guard defaults.object(forKey: key) != nil else {
            return defaultValue
        }

        return defaults.bool(forKey: key)
    }
}
