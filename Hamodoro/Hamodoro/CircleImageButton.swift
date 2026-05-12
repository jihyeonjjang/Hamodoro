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
    let diameter: CGFloat
    let action: () -> Void

    init(imageName: String, title: String, diameter: CGFloat = HamodoroDesign.Layout.buttonDiameter, action: @escaping () -> Void) {
        self.imageName = imageName
        self.systemName = nil
        self.diameter = diameter
        self.action = action
    }

    init(systemName: String, title: String, diameter: CGFloat = HamodoroDesign.Layout.buttonDiameter, action: @escaping () -> Void) {
        self.imageName = nil
        self.systemName = systemName
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
            }
            .frame(width: diameter, height: diameter)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var icon: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: diameter * 0.58, height: diameter * 0.58)
        } else if let systemName {
            Image(systemName: systemName)
                .font(.system(size: diameter * 0.38, weight: .semibold))
                .foregroundStyle(HamodoroDesign.Color.buttonIcon)
        }
    }
}
