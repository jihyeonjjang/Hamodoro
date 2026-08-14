//
//  OnboardingView.swift
//  Hamodoro
//

import SwiftUI
import AppKit

struct OnboardingView: View {
    @ObservedObject var appSettingsStore: AppSettingsStore
    @Environment(\.dismiss) private var dismiss

    private enum Step {
        case notifications
        case launchAtLogin
    }

    @State private var step: Step = .notifications

    var body: some View {
        VStack(spacing: 20) {
            Image("ham")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            switch step {
            case .notifications:
                notificationsStep
            case .launchAtLogin:
                launchAtLoginStep
            }
        }
        .padding(28)
        .frame(width: 320)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
        .onDisappear {
            // Restore accessory (no Dock icon) mode once onboarding closes, however it
            // closes — matches the .regular switch MenuBarLabelView makes to let this
            // window become key in the first place.
            NSApp.setActivationPolicy(.accessory)
        }
    }

    private var notificationsStep: some View {
        VStack(spacing: 12) {
            Text("햄모도로에 오신 걸 환영해요!")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(HamodoroDesign.Color.primaryText)

            Text("집중이나 휴식이 끝날 때 알림을 받고 싶으시다면, 아래 버튼을 누르고 우측 상단에서 허용을 눌러주세요.")
                .font(.system(size: 13))
                .foregroundStyle(HamodoroDesign.Color.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task {
                    await TimerNotificationManager.shared.requestAuthorization()
                    step = .launchAtLogin
                }
            } label: {
                Text("알림 허용하기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
        }
    }

    private var launchAtLoginStep: some View {
        VStack(spacing: 12) {
            Text("로그인 시 자동으로 실행할까요?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(HamodoroDesign.Color.primaryText)

            Text("맥을 켤 때마다 햄모도로를 직접 열지 않아도 돼요.")
                .font(.system(size: 13))
                .foregroundStyle(HamodoroDesign.Color.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Toggle("로그인 시 자동 실행", isOn: launchAtLoginBinding)
                .toggleStyle(.switch)
                .padding(.top, 4)

            Button {
                appSettingsStore.markOnboardingCompleted()
                dismiss()
            } label: {
                Text("완료")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.launchAtLoginEnabled },
            set: { appSettingsStore.updateLaunchAtLoginEnabled($0) }
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(appSettingsStore: AppSettingsStore())
    }
}
