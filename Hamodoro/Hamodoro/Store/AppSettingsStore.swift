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
    @Published private(set) var launchAtLoginEnabled: Bool

    init() {
        self.launchAtLoginEnabled = Self.isLaunchAtLoginEnabled
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

    private static var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
