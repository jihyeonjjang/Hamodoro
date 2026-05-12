//
//  HamodoroRootView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct HamodoroRootView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        HamodoroPopoverView(timerStore: timerStore)
    }
}

struct HamodoroRootView_Previews: PreviewProvider {
    static var previews: some View {
        HamodoroRootView(timerStore: PomodoroTimerStore())
    }
}
