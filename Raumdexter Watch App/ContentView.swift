//
//  ContentView.swift
//  Raumdexter Watch App
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WatchAppViewModel()

    var body: some View {
        ZStack {
            WatchTheme.background.ignoresSafeArea()

            if viewModel.saveStatus != .idle {
                saveResultView
            } else {
                switch viewModel.appState {
                case .initial:
                    initialView
                case .fieldProjecting:
                    fieldCenterView
                case .settingGoalDirection:
                    goalDirectionView
                case .tracking:
                    trackingView
                }
            }
        }
        .onAppear {
            viewModel.locationManager.requestAuthorization()
        }
    }

    // MARK: - Save result

    @ViewBuilder
    private var saveResultView: some View {
        switch viewModel.saveStatus {
        case .idle:
            EmptyView()

        case .sending:
            ScrollView {
                VStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(WatchTheme.accent)

                    Text("Menyimpan match…")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(WatchTheme.primaryText)
                }
                .padding(.horizontal, 6)
                .padding(.top, 40)
            }

        case .success:
            resultCard(
                icon: "checkmark.circle.fill",
                tint: WatchTheme.success,
                title: "Match Tersimpan",
                subtitle: "iPhone konfirmasi datanya udah masuk.",
                primaryButtonTitle: "Selesai",
                primaryTint: WatchTheme.success,
                primaryAction: { viewModel.acknowledgeSaveResult() }
            )

        case .queued:
            resultCard(
                icon: "icloud.and.arrow.up",
                tint: WatchTheme.accent,
                title: "Menunggu Koneksi",
                subtitle: "iPhone gak keliatan sekarang. Data dikirim di background begitu terhubung — belum bisa dipastikan tersimpan.",
                primaryButtonTitle: "Mengerti",
                primaryTint: WatchTheme.accent,
                primaryAction: { viewModel.acknowledgeSaveResult() }
            )

        case .failed(let message):
            resultCard(
                icon: "exclamationmark.triangle.fill",
                tint: WatchTheme.danger,
                title: "Gagal Tersimpan",
                subtitle: message,
                primaryButtonTitle: "Coba Lagi",
                primaryTint: WatchTheme.accent,
                primaryAction: { viewModel.retrySendMatch() },
                secondaryButtonTitle: "Buang Match",
                secondaryAction: { viewModel.discardFailedMatch() }
            )
        }
    }

    private func resultCard(
        icon: String,
        tint: Color,
        title: String,
        subtitle: String,
        primaryButtonTitle: String,
        primaryTint: Color,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(tint)
                    .padding(.top, 4)

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(WatchTheme.primaryText)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(WatchTheme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                PrimaryWatchButton(
                    title: primaryButtonTitle,
                    tint: primaryTint,
                    isLoading: viewModel.isEndingMatch,
                    action: primaryAction
                )
                .padding(.top, 4)

                if let secondaryButtonTitle, let secondaryAction {
                    Button(secondaryButtonTitle, action: secondaryAction)
                        .font(.system(size: 12, weight: .medium))
                        .buttonStyle(.plain)
                        .foregroundStyle(WatchTheme.tertiaryText)
                        .disabled(viewModel.isEndingMatch)
                }
            }
            .padding(.horizontal, 6)
        }
    }

    // MARK: - 1. Initial

    private var initialView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            Image(systemName: "sportscourt.fill")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(WatchTheme.accent)

            VStack(spacing: 3) {
                Text("RAUMDEXTER")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(WatchTheme.secondaryText)

                Text("Siap rekam match")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(WatchTheme.primaryText)
            }

            Spacer(minLength: 0)

            if viewModel.isLocationDenied {
                InlineErrorText(message: "Izin lokasi mati. Aktifkan di Settings › Privacy.")
            }

            PrimaryWatchButton(
                title: "Start Match",
                systemImage: "play.fill",
                tint: WatchTheme.success,
                isDisabled: viewModel.isLocationDenied,
                action: { viewModel.startMatch() }
            )
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 4)
    }

    // MARK: - 2. Field center

    private var fieldCenterView: some View {
        calibrationStep(
            step: 1,
            icon: "scope",
            title: "Berdiri di tengah lapangan",
            buttonTitle: "Submit Center",
            action: { await viewModel.submitFieldCenter() }
        )
    }

    // MARK: - 3. Goal direction

    private var goalDirectionView: some View {
        calibrationStep(
            step: 2,
            icon: "figure.walk",
            title: "Jalan ke gawang sendiri",
            buttonTitle: "Submit Direction",
            action: { await viewModel.submitOwnGoalDirection() }
        )
    }

    private func calibrationStep(
        step: Int,
        icon: String,
        title: String,
        buttonTitle: String,
        action: @escaping () async -> Void
    ) -> some View {
        ScrollView {
            VStack(spacing: 7) {
                StepBadge(step: step, total: 2)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(WatchTheme.accent)

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(WatchTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let errorMessage = viewModel.errorMessage {
                    InlineErrorText(message: errorMessage)
                }

                PrimaryWatchButton(
                    title: buttonTitle,
                    loadingTitle: "Mencari GPS…",
                    systemImage: "location.fill",
                    isLoading: viewModel.isRequestingLocation,
                    action: { Task { await action() } }
                )

                Button("Batal") { viewModel.cancelMatch() }
                    .font(.system(size: 12, weight: .medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(WatchTheme.tertiaryText)
                    .disabled(viewModel.isRequestingLocation)
            }
            .padding(.horizontal, 6)
        }
    }

    // MARK: - 4. Tracking

    private var trackingView: some View {
        ScrollView {
            VStack(spacing: 6) {
                liveHeader

                CounterRow(
                    label: "Goals",
                    count: viewModel.goals,
                    tint: WatchTheme.success,
                    onDecrement: viewModel.decrementGoal,
                    onIncrement: viewModel.incrementGoal
                )

                CounterRow(
                    label: "Assists",
                    count: viewModel.assists,
                    tint: WatchTheme.accent,
                    onDecrement: viewModel.decrementAssist,
                    onIncrement: viewModel.incrementAssist
                )

                PrimaryWatchButton(
                    title: "End Match",
                    loadingTitle: "Mengirim…",
                    systemImage: "stop.fill",
                    tint: WatchTheme.danger,
                    isLoading: viewModel.isEndingMatch,
                    action: { viewModel.endMatch() }
                )
                .padding(.top, 2)
            }
            .padding(.horizontal, 6)
        }
    }

    private var liveHeader: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Circle()
                    .fill(WatchTheme.danger)
                    .frame(width: 6, height: 6)

                Text("LIVE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(WatchTheme.secondaryText)

                Spacer()

                if let startDate = viewModel.matchStartDate {
                    Text(startDate, style: .timer)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(WatchTheme.secondaryText)
                        .monospacedDigit()
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(viewModel.distanceCoveredText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(WatchTheme.primaryText)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Spacer()

                Text("\(viewModel.matchSamples.count) pts")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(WatchTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(WatchTheme.surface)
        )
    }
}

#Preview {
    ContentView()
}
