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
        static let foreground = SwiftUI.Color(red: 0.25, green: 0.23, blue: 0.21)
        static let primaryText = SwiftUI.Color(red: 0.18, green: 0.16, blue: 0.14)
        static let secondaryText = SwiftUI.Color(red: 0.38, green: 0.34, blue: 0.29)
        static let icon = SwiftUI.Color(red: 0.34, green: 0.32, blue: 0.29)
        static let buttonIcon = SwiftUI.Color(red: 0.22, green: 0.20, blue: 0.18)
        static let buttonStroke = SwiftUI.Color(red: 0.25, green: 0.24, blue: 0.22)
        static let progressTrack = SwiftUI.Color(red: 0.88, green: 0.87, blue: 0.84)
        static let systemAccent = SwiftUI.Color(nsColor: .controlAccentColor)
        static let background = SwiftUI.Color(nsColor: .windowBackgroundColor)
    }
}
