//
//  CycleSelectorView.swift
//  Hamodoro
//
//  Created by 지현 on 5/12/26.
//

import SwiftUI

struct CycleSelectorView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        VStack(spacing: 0) {
            if let previousCycleCount {
                cycleNumber(previousCycleCount, isSelected: false)
                    .onTapGesture {
                        select(previousCycleCount)
                    }
            } else {
                hiddenCycleNumber
            }

            cycleNumber(timerStore.selectedCycleCount, isSelected: true)

            if let nextCycleCount {
                cycleNumber(nextCycleCount, isSelected: false)
                    .onTapGesture {
                        select(nextCycleCount)
                    }
            } else {
                hiddenCycleNumber
            }
        }
        .frame(width: HamodoroDesign.Layout.cyclePickerWidth, height: HamodoroDesign.Layout.cyclePickerHeight)
        .clipped()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 8)
                .onEnded { value in
                    if value.translation.height < 0 {
                        increment()
                    } else if value.translation.height > 0 {
                        decrement()
                    }
                }
        )
    }

    private var previousCycleCount: Int? {
        guard timerStore.selectedCycleCount > 1 else { return nil }
        return timerStore.selectedCycleCount - 1
    }

    private var nextCycleCount: Int? {
        guard timerStore.selectedCycleCount < 10 else { return nil }
        return timerStore.selectedCycleCount + 1
    }

    private var hiddenCycleNumber: some View {
        Color.clear
            .frame(width: HamodoroDesign.Layout.cyclePickerWidth, height: 21)
    }

    private func cycleNumber(_ cycleCount: Int, isSelected: Bool) -> some View {
        Text("\(cycleCount)")
            .font(.hakgyoansimKkokkomaRegular(size: isSelected ? 34 : 18))
            .foregroundStyle(isSelected ? HamodoroDesign.Color.primaryText : HamodoroDesign.Color.secondaryText.opacity(0.45))
            .frame(width: HamodoroDesign.Layout.cyclePickerWidth, height: isSelected ? 34 : 21)
    }

    private func select(_ cycleCount: Int) {
        timerStore.selectedCycleCount = cycleCount
    }

    private func increment() {
        timerStore.selectedCycleCount = min(10, timerStore.selectedCycleCount + 1)
    }

    private func decrement() {
        timerStore.selectedCycleCount = max(1, timerStore.selectedCycleCount - 1)
    }
}
