//
//  TaskRow.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: Task
    
    private let doneTaskColor = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00) // #dcdde1
    private let pastDueDateColor = UIColor(red: 194/255, green: 54/255, blue: 22/255, alpha: 1.00) // #c23616
    
    var body: some View {
        HStack {
            Image(uiImage: task.photo.uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)  // Updated frame size
                .cornerRadius(10)
            VStack(alignment: .leading) {
                HStack {
                    Text(task.state.rawValue)
                        .font(.system(size: 16, weight: .bold)) // Increase the font size and set the weight to bold
                        .foregroundColor(statusColor(for: task.state)) // Set the color based on the state
                        .onTapGesture {
                            task.toggleState() // Toggle the state when tapped
                        }
                    Spacer()
                    Text("\(task.dueDate, formatter: Self.dateFormatter)")
                        .strikethrough(task.state == .done)
                        .foregroundColor(dateColor(for: task)) // apply color here
                }
                Text(task.notes)
            }
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    // Helper function to get the color for the state
    private func statusColor(for state: TaskState) -> Color {
        switch state {
        case .new:
            return Color(paleGreenColor)
        case .doing:
            return Color(softYellowColor)
        case .done:
            return Color(paleLavenderColor)
        }
    }
    
    // Helper function to get the color for the date based on the task's state and due date
    private func dateColor(for task: Task) -> Color {
        if task.state == .done {
            return Color(doneTaskColor)
        } else if Calendar.current.isDateInToday(task.dueDate) {
            return Color(UIColor(red: 0/255, green: 168/255, blue: 255/255, alpha: 1.00)) // #00a8ff
        } else if task.dueDate < Date() {
            return Color(pastDueDateColor)
        } else {
            return Color.primary
        }
    }

    // Define the color values
    private let paleGreenColor = UIColor(red: 0.30, green: 0.82, blue: 0.22, alpha: 1.00)
    private let softYellowColor = UIColor(red: 0.98, green: 0.77, blue: 0.19, alpha: 1.00)
    private let paleLavenderColor = UIColor(red: 0.61, green: 0.53, blue: 1.00, alpha: 1.00)
}
