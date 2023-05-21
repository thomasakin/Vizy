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

    var body: some View {
        HStack {
            Image(uiImage: task.photo.uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(task.state.rawValue)
                    .font(.system(size: 16, weight: .bold)) // Increase the font size and set the weight to bold
                    .foregroundColor(statusColor(for: task.state)) // Set the color based on the state
                    .onTapGesture {
                        task.toggleState() // Toggle the state when tapped
                    }
                Text("\(task.dueDate, formatter: Self.dateFormatter)")
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
    
    // Define the color values
    private let paleGreenColor = UIColor(red: 0.725, green: 0.894, blue: 0.737, alpha: 1.0)
    private let softYellowColor = UIColor(red: 0.953, green: 0.925, blue: 0.682, alpha: 1.0)
    private let paleLavenderColor = UIColor(red: 0.839, green: 0.796, blue: 0.925, alpha: 1.0)
}
