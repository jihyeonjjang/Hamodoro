//
//  SettingsView.swift
//  Hamodoro
//
//  Created by 지현 on 5/13/26.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var timerStore: PomodoroTimerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("설정")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(HamodoroDesign.Color.primaryText)

            List {
                durationPickerRow(
                    title: "집중",
                    minutes: focusMinutesBinding
                )

                durationPickerRow(
                    title: "휴식",
                    minutes: breakMinutesBinding
                )
            }
            .listStyle(.inset)
            .scrollDisabled(true)
            .frame(height: 104)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
        .frame(minWidth: 300)
        .background(HamodoroDesign.Color.background)
    }

    private var focusMinutesBinding: Binding<Int> {
        Binding(
            get: { timerStore.focusMinutes },
            set: { timerStore.updateFocusMinutes($0) }
        )
    }

    private var breakMinutesBinding: Binding<Int> {
        Binding(
            get: { timerStore.breakMinutes },
            set: { timerStore.updateBreakMinutes($0) }
        )
    }

    private func durationPickerRow(title: String, minutes: Binding<Int>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(HamodoroDesign.Color.foreground)

            Spacer()

            MinuteComboBox(selection: minutes)
                .frame(width: 92, height: 24)
        }
        .frame(height: 44)
    }
}

struct MinuteComboBox: NSViewRepresentable {
    @Binding var selection: Int

    func makeNSView(context: Context) -> NSComboBox {
        let comboBox = NSComboBox()
        comboBox.usesDataSource = false
        comboBox.completes = true
        comboBox.isEditable = false
        comboBox.numberOfVisibleItems = 10
        comboBox.addItems(withObjectValues: (1...60).map { "\($0)분" })
        comboBox.selectItem(at: selection - 1)
        comboBox.delegate = context.coordinator
        return comboBox
    }

    func updateNSView(_ comboBox: NSComboBox, context: Context) {
        context.coordinator.update(comboBox, selection: selection)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    final class Coordinator: NSObject, NSComboBoxDelegate {
        @Binding private var selection: Int
        private var isUpdatingComboBox = false

        init(selection: Binding<Int>) {
            self._selection = selection
        }

        func update(_ comboBox: NSComboBox, selection: Int) {
            let selectedIndex = selection - 1
            guard comboBox.indexOfSelectedItem != selectedIndex else { return }

            isUpdatingComboBox = true
            comboBox.selectItem(at: selectedIndex)
            isUpdatingComboBox = false
        }

        func comboBoxSelectionDidChange(_ notification: Notification) {
            guard !isUpdatingComboBox else { return }
            guard let comboBox = notification.object as? NSComboBox else { return }
            let selectedMinute = min(60, max(1, comboBox.indexOfSelectedItem + 1))
            guard selection != selectedMinute else { return }

            DispatchQueue.main.async {
                self.selection = selectedMinute
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(timerStore: PomodoroTimerStore())
    }
}
