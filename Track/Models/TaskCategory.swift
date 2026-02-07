//
//  TaskCategory.swift
//  Track
//

import Foundation
import SwiftUI

enum TaskCategory: String, CaseIterable, Codable {
    case unassigned = "Unassigned"
    case thesis = "Thesis"
    case assignment = "Assignment"
    case reading = "Reading"
    case research = "Research"
    case meeting = "Meeting"
    case coding = "Coding"
    case design = "Design"
    case writing = "Writing"
    case review = "Review"
    
    var displayName: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .unassigned: return "square.dashed"
        case .thesis: return "doc.text"
        case .assignment: return "checkmark.square"
        case .reading: return "book"
        case .research: return "magnifyingglass"
        case .meeting: return "person.2"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .design: return "paintbrush"
        case .writing: return "pencil"
        case .review: return "eye"
        }
    }
    
    var color: Color {
        switch self {
        case .unassigned: return Color(.systemGray).opacity(0.15)
        case .thesis: return Color.blue.opacity(0.15)
        case .assignment: return Color.orange.opacity(0.2)
        case .reading: return Color.green.opacity(0.15)
        case .research: return Color.purple.opacity(0.15)
        case .meeting: return Color.pink.opacity(0.15)
        case .coding: return Color.cyan.opacity(0.15)
        case .design: return Color.indigo.opacity(0.15)
        case .writing: return Color.yellow.opacity(0.25)
        case .review: return Color.teal.opacity(0.15)
        }
    }
    
    var textColor: Color {
        switch self {
        case .unassigned: return .primary
        case .thesis: return .blue
        case .assignment: return .orange
        case .reading: return .green
        case .research: return .purple
        case .meeting: return .pink
        case .coding: return .cyan
        case .design: return .indigo
        case .writing: return Color(.systemYellow).opacity(0.9)
        case .review: return .teal
        }
    }
}
