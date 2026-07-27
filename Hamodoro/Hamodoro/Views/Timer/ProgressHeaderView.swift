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
        ZStack {
            // Idle state: Show app title
            if timerStore.phase == .idle {
                VStack(spacing: 4) {
                    Text("햄모도로")
                        .font(.hakgyoansimKkokkomaRegular(size: 36))
                        .foregroundStyle(HamodoroDesign.Color.primaryText)

                    if let todayStudyTimeText = timerStore.todayStudyTimeText {
                        Text(todayStudyTimeText)
                            .font(.hakgyoansimKkokkomaRegular(size: 16))
                            .foregroundStyle(HamodoroDesign.Color.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 24)
            }

            // Active state: Show progress
            HStack(spacing: headerItemSpacing) {
                Text(headerEmoji)
                    .font(.system(size: headerEmojiSize))
                    .frame(width: headerSideSlotWidth, height: 24, alignment: .trailing)

                ProgressView(value: timerStore.remainingProgress)
                    .progressViewStyle(HamodoroProgressStyle())
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)

                Text(timerStore.remainingTimeText)
                    .font(.hakgyoansimKkokkomaRegular(size: 15))
                    .foregroundStyle(HamodoroDesign.Color.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .monospacedDigit()
                    .frame(width: headerSideSlotWidth, alignment: .leading)
            }
            .opacity(timerStore.phase == .idle ? 0 : 1)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 24)
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
