//
//  ProgressHeaderView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct ProgressHeaderView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        HStack(spacing: 8) {
            Image(headerImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            ProgressView(value: timerStore.progress)
                .progressViewStyle(HamodoroProgressStyle())
                .frame(height: 5)

            Text(timerStore.remainingTimeText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(HamodoroDesign.Color.foreground)
                .frame(width: 44, alignment: .trailing)
        }
        .opacity(timerStore.phase == .idle ? 0 : 1)
        .frame(height: 24)
    }

    private var headerImageName: String {
        switch timerStore.phase {
        case .idle, .breakTime:
            return "macbook"
        case .focus:
            return "iceCoffee"
        }
    }
}

struct HamodoroProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(HamodoroDesign.Color.progressTrack)

                Capsule()
                    .fill(HamodoroDesign.Color.progressFill)
                    .frame(width: proxy.size.width * (configuration.fractionCompleted ?? 0))
            }
        }
    }
}
