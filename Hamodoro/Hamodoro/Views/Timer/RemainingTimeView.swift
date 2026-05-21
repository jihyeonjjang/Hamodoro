//
//  RemainingTimeView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct RemainingTimeView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        ZStack {
            if timerStore.phase == .idle {
                idleContent
            } else {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    activeContent
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 48)
        .padding(.bottom, -14)
    }

    private var idleContent: some View {
        HStack(spacing: 0) {
            Text(timerStore.focusFirstEndClockText)
                .monospacedDigit()

            Text("까지 햄모도로와 함께해요")
        }
        .font(.system(size: 13, weight: .medium, design: .rounded))
        .foregroundStyle(HamodoroDesign.Color.secondaryText)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }

    private var activeContent: some View {
        Group {
            Text("\(timerStore.remainingMinutes)")
                .font(.system(size: 42, weight: .regular, design: .rounded))
                .foregroundStyle(HamodoroDesign.Color.primaryText)

            Text("분 남음")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(HamodoroDesign.Color.secondaryText)
                .padding(.bottom, 5)
        }
    }
}
