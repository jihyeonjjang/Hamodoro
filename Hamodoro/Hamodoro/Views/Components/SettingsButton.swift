//
//  SettingsButton.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI
import AppKit

struct SettingsButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: HamodoroWindow.settings)
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HamodoroDesign.Color.icon)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}
