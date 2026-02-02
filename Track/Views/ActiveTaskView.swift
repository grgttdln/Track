//
//  ActiveTaskView.swift
//  Track
//

import SwiftUI
import SwiftData

struct ActiveTaskView: View {
    @Bindable var task: TrackTask
    @Binding var now: Date
    @Binding var timerRunning: Bool
    var onStop: () -> Void

    private let controlHeight: CGFloat = 44
    private let playPauseButtonWidth: CGFloat = 44
    private let finishTaskMinWidth: CGFloat = 180

    private var category: TaskCategory {
        TaskCategory(rawValue: task.taskType) ?? .unassigned
    }
    
    /// Displayed time: if running, calculate from startedAt; if paused, show saved durationSeconds
    private var displayedTime: String {
        if timerRunning, let start = task.startedAt {
            // Running: show elapsed time from start
            return formattedElapsed(from: start, to: now)
        } else {
            // Paused: show saved duration
            return task.durationSeconds.formattedDuration
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Header at the top
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                            .foregroundStyle(.cyan)
                        Text(category.displayName.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    Text(task.descriptionText)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
                    .frame(height: 8)

                // Centered timer and buttons
                VStack(spacing: 12) {
                    Text(displayedTime)
                        .font(.system(size: 64, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        // Play/Pause chip
                        Button {
                            toggleTimer()
                        } label: {
                            HStack(spacing: 6) {
                                PlayPauseIcon(isRunning: timerRunning)
                            }
                            .frame(width: playPauseButtonWidth, height: controlHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.thinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)

                        // Finish Task chip
                        Button {
                            onStop()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Finish Task")
                                    .font(.headline)
                            }
                            .padding(.horizontal, 16)
                            .frame(minWidth: finishTaskMinWidth)
                            .frame(height: controlHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.thinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggleTimer() {
        if timerRunning {
            // Pausing: save current elapsed time and clear startedAt
            if let start = task.startedAt {
                task.durationSeconds = Date().timeIntervalSince(start)
            }
            task.startedAt = nil
            // Keep isActive = true so the task stays visible
            timerRunning = false
        } else {
            // Resuming: set startedAt adjusted for already accumulated time
            task.startedAt = Date().addingTimeInterval(-task.durationSeconds)
            timerRunning = true
        }
    }
}

#Preview {
    let task = TrackTask(descriptionText: "Working on thesis chapter 3", taskType: TaskCategory.thesis.rawValue, startedAt: Date(), isActive: true)
    return ActiveTaskView(task: task, now: .constant(Date()), timerRunning: .constant(true)) {}
        .frame(width: 400, height: 300)
        .padding()
}
