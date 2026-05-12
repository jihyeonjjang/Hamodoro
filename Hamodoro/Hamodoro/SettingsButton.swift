//
//  SettingsButton.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct SettingsButton: View {
    var body: some View {
        Button {} label: {
            Image(systemName: "gearshape")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HamodoroDesign.Color.icon)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}
