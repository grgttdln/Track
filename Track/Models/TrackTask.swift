//
//  TrackTask.swift
//  Track
//

import Foundation
import SwiftData

@Model
final class TrackTask {
    var createdAt: Date
    var startedAt: Date?
    var endedAt: Date?
    var durationSeconds: Double
    var descriptionText: String
    var taskType: String
    var isActive: Bool
    var isCompleted: Bool
    var taskDate: Date

    init(descriptionText: String, taskType: String, taskDate: Date = Date(), startedAt: Date? = nil, isActive: Bool = false, isCompleted: Bool = false, durationSeconds: Double = 0) {
        self.createdAt = Date()
        self.startedAt = startedAt
        self.endedAt = nil
        self.durationSeconds = durationSeconds
        self.descriptionText = descriptionText
        self.taskType = taskType
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.taskDate = Calendar.current.startOfDay(for: taskDate)
    }
}

// MARK: - Computed Properties

extension TrackTask {
    /// Whether the task is currently running
    var isRunning: Bool {
        isActive && !isCompleted
    }
    
    /// Formatted duration string (HH:MM:SS or MM:SS)
    var formattedDuration: String {
        durationSeconds.formattedDuration
    }
}
