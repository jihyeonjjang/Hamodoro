//
//  HomeButton.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct HomeButton: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        Button {
            timerStore.returnHome()
        } label: {
            Image(systemName: "house")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HamodoroDesign.Color.icon)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}
