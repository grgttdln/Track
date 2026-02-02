//
//  TimeFormatter.swift
//  Track
//

import Foundation

extension TimeInterval {
    /// Formats the time interval as HH:MM:SS or MM:SS
    var formattedDuration: String {
        let totalSeconds = Int(max(0, self))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Formats elapsed time between two dates
func formattedElapsed(from start: Date, to end: Date) -> String {
    let interval = end.timeIntervalSince(start)
    return interval.formattedDuration
}
