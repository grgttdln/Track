//
//  CategoryDropdownButton.swift
//  Track
//

import SwiftUI

struct CategoryDropdownButton: View {
    @Binding var selectedCategory: TaskCategory
    @State private var isExpanded: Bool = false
    
    var body: some View {
        // Selected category button
        Button {
            isExpanded.toggle()
        } label: {
            CategoryPill(category: selectedCategory)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isExpanded, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                        isExpanded = false
                    } label: {
                        CategoryPill(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
        }
    }
}

struct CategoryPill: View {
    let category: TaskCategory
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 11, weight: .medium))
            Text(category.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(category.textColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(category.color)
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(TaskCategory.allCases, id: \.self) { category in
            CategoryPill(category: category)
        }
    }
    .padding()
}
