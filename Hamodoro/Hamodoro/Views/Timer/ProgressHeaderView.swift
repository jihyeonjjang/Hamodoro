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
        HStack(spacing: headerItemSpacing) {
            Text(headerEmoji)
                .font(.system(size: headerEmojiSize))
                .frame(width: headerSideSlotWidth, height: 24, alignment: .trailing)

            ProgressView(value: timerStore.remainingProgress)
                .progressViewStyle(HamodoroProgressStyle())
                .frame(height: 5)
                .frame(maxWidth: .infinity)

            Text(timerStore.remainingTimeText)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(HamodoroDesign.Color.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .monospacedDigit()
                .frame(width: headerSideSlotWidth, alignment: .leading)
        }
        .opacity(timerStore.phase == .idle ? 0 : 1)
        .frame(maxWidth: .infinity)
        .frame(height: 24)
    }

    private let headerSideSlotWidth: CGFloat = 38
    private let headerItemSpacing: CGFloat = 6

    private var headerEmoji: String {
        switch timerStore.phase {
        case .idle, .breakTime:
            return "💻"
        case .focus:
            return "☕️"
        }
    }

    private var headerEmojiSize: CGFloat {
        switch timerStore.phase {
        case .idle, .breakTime:
            return 13
        case .focus:
            return 15
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
                    .fill(HamodoroDesign.Color.systemAccent)
                    .frame(width: proxy.size.width * (configuration.fractionCompleted ?? 0))
            }
        }
    }
}
