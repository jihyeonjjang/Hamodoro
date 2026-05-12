//
//  ContentView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        HamodoroPopoverView(timerStore: timerStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timerStore: PomodoroTimerStore())
    }
}
