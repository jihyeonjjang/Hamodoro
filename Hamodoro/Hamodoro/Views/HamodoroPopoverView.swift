//
//  HamodoroPopoverView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct HamodoroPopoverView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HamodoroDesign.Color.background
                .ignoresSafeArea()

            VStack(spacing: 10) {
                ProgressHeaderView(timerStore: timerStore)
                    .padding(.top, HamodoroDesign.Layout.headerTopPadding)
                    .padding(.horizontal, HamodoroDesign.Layout.headerSidePadding)

                Spacer(minLength: 0)

                RemainingTimeView(timerStore: timerStore)
                HamsterImageView(phase: timerStore.phase, isRunning: timerStore.isRunning)

                Spacer(minLength: 0)

                ControlButtonsView(timerStore: timerStore)
                    .padding(.bottom, HamodoroDesign.Layout.controlsBottomPadding)
            }
            .padding(.horizontal, HamodoroDesign.Layout.horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(HamodoroDesign.Color.background)

            SettingsButton()
                .padding(.trailing, HamodoroDesign.Layout.settingsPadding)
                .padding(.bottom, HamodoroDesign.Layout.settingsPadding)
        }
        .overlay(alignment: .topLeading) {
            HomeButton(timerStore: timerStore)
                .padding(.leading, HamodoroDesign.Layout.settingsPadding)
                .padding(.top, HamodoroDesign.Layout.settingsPadding)
        }
        .frame(width: HamodoroDesign.Layout.popoverWidth, height: HamodoroDesign.Layout.popoverHeight)
    }
}
