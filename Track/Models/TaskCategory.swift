//
//  TaskCategory.swift
//  Track
//

import Foundation

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
}
