//
//  HamodoroDesign.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

enum HamodoroDesign {
    enum Layout {
        static let popoverWidth: CGFloat = 275
        static let popoverHeight: CGFloat = 461
        static let horizontalPadding: CGFloat = 16
        static let headerTopPadding: CGFloat = 52
        static let headerSidePadding: CGFloat = 0
        static let controlsBottomPadding: CGFloat = 36
        static let settingsPadding: CGFloat = 14
        static let hamsterImageSize: CGFloat = 188
        static let buttonDiameter: CGFloat = 48
        static let primaryButtonDiameter: CGFloat = 58
        static let cyclePickerWidth: CGFloat = 58
        static let cyclePickerHeight: CGFloat = 76
    }

    enum Color {
        static let foreground = adaptive(light: (0.25, 0.23, 0.21), dark: (0.82, 0.78, 0.72))
        static let primaryText = adaptive(light: (0.18, 0.16, 0.14), dark: (0.96, 0.93, 0.88))
        static let secondaryText = adaptive(light: (0.38, 0.34, 0.29), dark: (0.68, 0.63, 0.55))
        static let icon = adaptive(light: (0.34, 0.32, 0.29), dark: (0.72, 0.68, 0.60))
        static let buttonIcon = adaptive(light: (0.22, 0.20, 0.18), dark: (0.90, 0.87, 0.81))
        static let buttonStroke = adaptive(light: (0.25, 0.24, 0.22), dark: (0.42, 0.40, 0.36))
        static let progressTrack = adaptive(light: (0.88, 0.87, 0.84), dark: (0.30, 0.28, 0.25))
        static let systemAccent = SwiftUI.Color(nsColor: .controlAccentColor)
        static let background = SwiftUI.Color(nsColor: .windowBackgroundColor)

        private static func adaptive(
            light: (Double, Double, Double),
            dark: (Double, Double, Double)
        ) -> SwiftUI.Color {
            SwiftUI.Color(nsColor: NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                let (r, g, b) = isDark ? dark : light
                return NSColor(red: r, green: g, blue: b, alpha: 1.0)
            })
        }
    }
}
