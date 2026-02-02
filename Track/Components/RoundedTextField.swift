//
//  RoundedTextField.swift
//  Track
//

import SwiftUI

struct RoundedTextField: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        TextField(placeholder, text: $text, prompt: Text(placeholder))
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
    }
}

#Preview {
    RoundedTextField(text: .constant(""), placeholder: "Type something...")
        .padding()
}
