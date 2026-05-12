//
//  HamsterImageView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct HamsterImageView: View {
    let phase: PomodoroTimerStore.Phase
    let isRunning: Bool

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(
                width: HamodoroDesign.Layout.hamsterImageSize,
                height: HamodoroDesign.Layout.hamsterImageSize
            )
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 18)
    }

    private var imageName: String {
        switch phase {
        case .idle:
            return "ham"
        case .focus:
            return isRunning ? "macHam" : "standingHam"
        case .breakTime:
            return isRunning ? "coffeeHam" : "standingHam"
        }
    }
}
