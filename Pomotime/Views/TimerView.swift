//
//  TimerView.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI
import Combine
import Foundation

struct TimerView: View {
    @EnvironmentObject var timers: Timers

    @AppStorage(
        "timer_stage"
    ) private var storedStageRaw: String = Stage.work.rawValue
    @AppStorage("timer_isRunning") private var storedIsRunning: Bool = false
    @AppStorage(
        "timer_endDate"
    ) private var storedEndDate: Double = 0 // timeIntervalSince1970
    @AppStorage(
        "timer_completedWorkSessions"
    ) private var storedCompletedWorkSessions: Int = 0

    @State private var remaining: Int = 0 

    private var stage: Stage { Stage(rawValue: storedStageRaw) ?? .work }
    private var isRunning: Bool { storedIsRunning }
    private var endDate: Date { Date(timeIntervalSince1970: storedEndDate) }
    private var completedWorkSessions: Int { storedCompletedWorkSessions }

    // MARK: - Timer State
    private enum Stage: String, CaseIterable {
        case work = "Work"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"

        var color: Color {
            switch self {
            case .work: return Color(
                red: 1.0,
                green: 0.39,
                blue: 0.28
            ) // tomato
            case .shortBreak: return Color.green
            case .longBreak: return Color.blue
            }
        }
    }

    // Long break after this many work sessions
    private let longBreakInterval = 4

    // A simple timer that ticks every second when running
    @State private var tick: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    )
        .autoconnect()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 12)

                // Stage label
                Text(stage.rawValue)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(stage.color)

                // Circular countdown
                ZStack {
                    Circle()
                        .stroke(stage.color.opacity(0.15), lineWidth: 20)
                        .frame(width: 260, height: 260)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            stage.color,
                            style: StrokeStyle(
                                lineWidth: 20,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 260, height: 260)
                        .animation(.easeInOut(duration: 0.2), value: progress)

                    VStack(spacing: 8) {
                        Text(formattedTime(remaining))
                            .font(
                                .system(
                                    size: 48,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.linear, value: formattedTime(remaining))
                        
                        Text(isRunning ? "Running" : "Paused")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)

                // Controls
                HStack(spacing: 16) {
                    Button(action: toggleRun) {
                        HStack(spacing: 8) {
                            Image(
                                systemName: isRunning ? "pause.fill" : "play.fill"
                            )
                            Text(isRunning ? "Pause" : "Start")
                        }
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(stage.color)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }

                    Button(role: .destructive, action: reset) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                    }
                }

                // Small status line
                Text(
                    "Completed: \(completedWorkSessions) work session\(completedWorkSessions == 1 ? "" : "s")"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                Spacer()

#if DEBUG
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("APP IS RUNNING IN DEBUG MODE!")
                    Text("Debug output:")
                        .font(.caption).foregroundStyle(.secondary)
                    Text("Work duration: \(timers.workSession) min")
                    Text("Short break duration: \(timers.shortBreak) min")
                    Text("Long break duration: \(timers.longBreak) min")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
#endif
            }
            .padding()
            .navigationTitle("Timer")
            .toolbarBackground(
                Color(red: 1.0, green: 0.39, blue: 0.28),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .onReceive(tick) { _ in
                let now = Date()
                if storedIsRunning {
                    let secondsLeft = Int(
                        max(endDate.timeIntervalSince(now), 0)
                    )
                    remaining = secondsLeft
                    if secondsLeft == 0 {
                        advanceStage()
                    }
                } else {
                    // Keep remaining up to date
                    if storedIsRunning {
                        let secondsLeft = Int(
                            max(endDate.timeIntervalSince(now), 0)
                        )
                        if secondsLeft >= 0 && remaining != secondsLeft {
                            remaining = secondsLeft
                        }
                    }
                }
            }
            .onAppear {
                // If we have an endDate set, derive remaining; otherwise configure a fresh stage
                if storedEndDate > 0 {
                    let now = Date()
                    let secondsLeft = Int(
                        max(endDate.timeIntervalSince(now), 0)
                    )
                    remaining = secondsLeft > 0 ? secondsLeft : totalForStage
                    // If time elapsed in background, advance to next stage and pause
                    if secondsLeft == 0 && storedIsRunning {
                        advanceStage()
                        storedIsRunning = false
                    }
                } else {
                    configureForCurrentStage(resetElapsed: true)
                }
            }
        }
    }

    // MARK: - Derived values
    private var totalForStage: Int {
        switch stage {
        case .work: return timers.workSession * 60
        case .shortBreak: return timers.shortBreak * 60
        case .longBreak: return timers.longBreak * 60
        }
    }

    private var progress: CGFloat {
        let total = max(totalForStage, 1)
        let done = total - remaining
        return CGFloat(max(min(Double(done) / Double(total), 1.0), 0.0))
    }

    // MARK: - Actions
    private func toggleRun() {
        if remaining == 0 { // if finished, restart current stage
            configureForCurrentStage(resetElapsed: true)
        }
        if storedIsRunning {
            
            
            storedIsRunning = false
        } else {
            // Start/resume: set endDate from now + remaining
            storedEndDate = Date()
                .addingTimeInterval(
                    TimeInterval(remaining)
                ).timeIntervalSince1970
            storedIsRunning = true
        }
    }

    private func reset() {
        storedIsRunning = false
        storedEndDate = 0
        storedCompletedWorkSessions = 0 
        storedStageRaw = Stage.work.rawValue
        configureForCurrentStage(resetElapsed: true)
    }

    private func advanceStage() {
        if stage == .work {
            storedCompletedWorkSessions += 1
            if storedCompletedWorkSessions % longBreakInterval == 0 {
                storedStageRaw = Stage.longBreak.rawValue
            } else {
                storedStageRaw = Stage.shortBreak.rawValue
            }
        } else {
            storedStageRaw = Stage.work.rawValue
        }
        configureForCurrentStage(resetElapsed: true)
        storedIsRunning = false
        storedEndDate = 0
    }

    private func configureForCurrentStage(resetElapsed: Bool) {
        let total = totalForStage
        remaining = total
        if resetElapsed {
            storedEndDate =  0
        }
    }

    // MARK: - Helpers
    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    TimerView().environmentObject(Timers())
}
