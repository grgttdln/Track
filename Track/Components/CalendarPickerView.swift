//
//  CalendarPickerView.swift
//  Track
//

import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    var onDismiss: () -> Void
    
    @State private var displayedMonth: Date
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    
    init(selectedDate: Binding<Date>, onDismiss: @escaping () -> Void) {
        self._selectedDate = selectedDate
        self.onDismiss = onDismiss
        self._displayedMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        
        // Get the first day of the month
        let firstDayOfMonth = monthInterval.start
        
        // Get weekday of first day (1 = Sunday, 2 = Monday, etc.)
        var weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Convert to Monday-based (0 = Monday, 6 = Sunday)
        weekday = (weekday + 5) % 7
        
        // Add nil for days before the first of the month
        for _ in 0..<weekday {
            days.append(nil)
        }
        
        // Add all days of the month
        var currentDate = firstDayOfMonth
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with month/year and navigation
            HStack {
                HStack(spacing: 4) {
                    Text(monthYearString)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 4)
            
            // Calendar grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        Button {
                            selectedDate = date
                            onDismiss()
                        } label: {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.body)
                                .fontWeight(isToday(date) ? .semibold : .regular)
                                .foregroundStyle(isSelected(date) ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                                .background(
                                    Circle()
                                        .fill(isSelected(date) ? Color.accentColor : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(isToday(date) && !isSelected(date) ? Color.accentColor : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    CalendarPickerView(selectedDate: .constant(Date())) {}
        .padding()
        .frame(width: 320, height: 280)
}
