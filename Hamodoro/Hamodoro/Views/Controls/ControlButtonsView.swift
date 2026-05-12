//
//  ControlButtonsView.swift
//  Hamodoro
//
//  Created by 지현 on 5/11/26.
//

import SwiftUI

struct ControlButtonsView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            switch timerStore.phase {
            case .idle:
                idleButtons
            case .focus:
                focusButtons
            case .breakTime:
                breakButtons
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var idleButtons: some View {
        Group {
            controlSlot {
                CircleImageButton(emoji: "☕️", title: "휴식") {
                    timerStore.startBreak()
                }
            }

            controlSlot {
                CycleSelectorView(timerStore: timerStore)
                    .frame(width: HamodoroDesign.Layout.cyclePickerWidth, height: HamodoroDesign.Layout.cyclePickerHeight)
            }

            controlSlot {
                CircleImageButton(emoji: "💻", title: "집중", emojiScale: 0.29, emojiOffsetX: 0) {
                    timerStore.startFocus()
                }
            }
        }
    }

    private var focusButtons: some View {
        Group {
            controlSlot {
                CircleImageButton(emoji: "☕️", title: "휴식") {
                    timerStore.startBreak()
                }
            }

            controlSlot {
                playPauseButton
            }

            controlSlot {
                resetButton
            }
        }
    }

    private var breakButtons: some View {
        Group {
            controlSlot {
                CircleImageButton(emoji: "💻", title: "집중", emojiScale: 0.29, emojiOffsetX: 0) {
                    timerStore.startFocus()
                }
            }

            controlSlot {
                playPauseButton
            }

            controlSlot {
                resetButton
            }
        }
    }

    private var playPauseButton: some View {
        CircleImageButton(
            systemName: timerStore.isRunning ? "pause.fill" : "play.fill",
            title: timerStore.isRunning ? "일시정지" : "재개",
            diameter: HamodoroDesign.Layout.primaryButtonDiameter
        ) {
            timerStore.togglePause()
        }
    }

    private var resetButton: some View {
        CircleImageButton(systemName: "arrow.clockwise", title: "초기화") {
            timerStore.reset()
        }
    }

    private func controlSlot<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(
                width: HamodoroDesign.Layout.primaryButtonDiameter,
                height: HamodoroDesign.Layout.cyclePickerHeight,
                alignment: .center
            )
    }
}
