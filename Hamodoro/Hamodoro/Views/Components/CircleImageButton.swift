//
//  CircleImageButton.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct CircleImageButton: View {
    let imageName: String?
    let systemName: String?
    let emoji: String?
    let emojiScale: CGFloat
    let emojiOffsetX: CGFloat
    let title: String
    let diameter: CGFloat
    let action: () -> Void

    init(imageName: String, title: String, diameter: CGFloat = HamodoroDesign.Layout.buttonDiameter, action: @escaping () -> Void) {
        self.imageName = imageName
        self.systemName = nil
        self.emoji = nil
        self.emojiScale = 0.34
        self.emojiOffsetX = 0
        self.title = title
        self.diameter = diameter
        self.action = action
    }

    init(
        emoji: String,
        title: String,
        diameter: CGFloat = HamodoroDesign.Layout.buttonDiameter,
        emojiScale: CGFloat = 0.34,
        emojiOffsetX: CGFloat = 1,
        action: @escaping () -> Void
    ) {
        self.imageName = nil
        self.systemName = nil
        self.emoji = emoji
        self.emojiScale = emojiScale
        self.emojiOffsetX = emojiOffsetX
        self.title = title
        self.diameter = diameter
        self.action = action
    }

    init(systemName: String, title: String, diameter: CGFloat = HamodoroDesign.Layout.buttonDiameter, action: @escaping () -> Void) {
        self.imageName = nil
        self.systemName = systemName
        self.emoji = nil
        self.emojiScale = 0.34
        self.emojiOffsetX = 0
        self.title = title
        self.diameter = diameter
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(HamodoroDesign.Color.background)
                    .overlay {
                        Circle()
                            .stroke(HamodoroDesign.Color.buttonStroke, lineWidth: 1)
                    }

                icon
                    .frame(width: diameter, height: diameter, alignment: .center)
            }
            .frame(width: diameter, height: diameter)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var icon: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: diameter * 0.58, height: diameter * 0.58)
                .frame(width: diameter, height: diameter, alignment: .center)
        } else if let systemName {
            Image(systemName: systemName)
                .font(.system(size: diameter * 0.38, weight: .semibold))
                .foregroundStyle(HamodoroDesign.Color.buttonIcon)
                .frame(width: diameter, height: diameter, alignment: .center)
        } else if let emoji {
            Text(emoji)
                .font(.system(size: diameter * emojiScale))
                .fixedSize()
                .frame(width: diameter, height: diameter, alignment: .center)
                .offset(x: emojiOffsetX)
        }
    }
}
