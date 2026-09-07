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
        VStack {
            if viewModel.appState == .tracking {
                Button("Start Match") {
                    viewModel.startMatch()
                }
            } else if viewModel.appState == .fieldProjecting {
                VStack(spacing: 10) {
                    Text("Please stand on the middle of the field")
                    Button("Submit Field Center") {
                        Task {
                            await viewModel.submitFieldCenter()
                        }
                    }
                }
            } else if viewModel.appState == .settingGoalDirection {
                VStack(spacing: 10) {
                    Text("Walk to your own goal")
                    Button("Submit Goal Direction") {
                        Task {
                            await viewModel.submitOwnGoalDirection()
                        }
                    }
                }
            } else if viewModel.appState == .initial {
                VStack(spacing: 10) {
                    counterRow(label: "Goal", count: viewModel.goals, onDecrement: viewModel.decrementGoal, onIncrement: viewModel.incrementGoal)
                    counterRow(label: "Assist", count: viewModel.assists, onDecrement: viewModel.decrementAssist, onIncrement: viewModel.incrementAssist)
                    
                    Spacer()
                    
                    HStack {
                        Text(viewModel.distanceCoveredText)
                            .font(.headline)
                        Spacer()
                        Button("End") {
                            viewModel.endMatch()
                        }
                        .font(.title3)
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.locationManager.requestAuthorization()
        }
    }
    
    private func counterRow(label: String, count: Int, onDecrement: @escaping () -> Void, onIncrement: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onDecrement) { Image(systemName: "minus") }
            Spacer()
            Text("\(count) \(label)")
            Spacer()
            Button(action: onIncrement) { Image(systemName: "plus") }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.purple.opacity(0.6)))
    }
}

#Preview {
    ContentView()
}
