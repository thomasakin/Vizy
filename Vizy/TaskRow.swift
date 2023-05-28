//
//  TaskRow.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct TaskRow: View {
    var task: CoreDataTask
    
    private let doneTaskColor = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00) // #dcdde1
    private let pastDueDateColor = UIColor(red: 194/255, green: 54/255, blue: 22/255, alpha: 1.00) // #c23616
    
    var body: some View {
        HStack {
            Image(uiImage: UIImage(data: task.photoData ?? Data()) ?? UIImage(named: "placeholder")!)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)  // Updated frame size
                .cornerRadius(10)
            VStack(alignment: .leading) {
                HStack {
                    Text(TaskState(rawValue: task.stateRaw ?? "")?.rawValue ?? "")
                        .font(.system(size: 16, weight: .bold)) // Increase the font size and set the weight to bold
                        .foregroundColor(statusColor(for: TaskState(rawValue: task.stateRaw ?? "") ?? .new)) // Set the color based on the state
                    Spacer()
                    if let dueDate = task.dueDate {
                        Text("\(dueDate, formatter: Self.dateFormatter)")
                            .strikethrough(TaskState(rawValue: task.stateRaw ?? "") == .done)
                            .foregroundColor(dateColor(for: task)) // apply color here
                    }
                }
                Text(task.note ?? "")
            }
        }//.padding()
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
    private func dateColor(for task: CoreDataTask) -> Color {
        if TaskState(rawValue: task.stateRaw ?? "") == .done {
            return Color(doneTaskColor)
        } else if let dueDate = task.dueDate, Calendar.current.isDateInToday(dueDate) {
            return Color(UIColor(red: 0/255, green: 168/255, blue: 255/255, alpha: 1.00)) // #00a8ff
        } else if let dueDate = task.dueDate, dueDate < Date() {
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
