//
//  CategoryDropdownButton.swift
//  Track
//

import SwiftUI

struct CategoryDropdownButton: View {
    @Binding var selectedCategory: TaskCategory
    
    var body: some View {
        Menu {
            ForEach(TaskCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Label(category.displayName, systemImage: category.icon)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selectedCategory.icon)
                    .font(.system(size: 12))
                Text(selectedCategory.displayName)
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        CategoryDropdownButton(selectedCategory: .constant(.unassigned))
        CategoryDropdownButton(selectedCategory: .constant(.thesis))
        CategoryDropdownButton(selectedCategory: .constant(.assignment))
    }
    .padding()
}
