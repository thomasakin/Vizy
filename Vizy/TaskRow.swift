//
//  TaskRow.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct TaskRow: View {
    let task: CoreDataTask
    let statusColor: Color

    var body: some View {
        HStack {
            if let data = task.photoData, let uiImage = UIImage(data: data) {
                let identifiableImage = IdentifiableImage(uiImage: uiImage)
                Image(uiImage: identifiableImage.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Text("Todo")
                            .foregroundColor(.black)
                            .font(.headline)
                    )
            }
            
            VStack(alignment: .leading) {
                Text(task.note ?? "")
                    .lineLimit(2)
                    .font(.headline)
                Text(task.dueDate ?? Date(), style: .date)
                    .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundColor(statusColor)
                .opacity(TaskState(rawValue: task.stateRaw ?? "") == .done ? 1.0 : 0.0)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    private func dueDateColor(for date: Date, state: TaskState) -> Color {
        let today = Calendar.current.startOfDay(for: Date())
        let dueDate = Calendar.current.startOfDay(for: date)

        if dueDate < today && state != .done {
            return Color(red: 194/255, green: 54/255, blue: 22/255)
        } else if Calendar.current.isDateInToday(dueDate) {
            return Color(red: 156/255, green: 136/255, blue: 255/255)
        } else if dueDate > today {
            return Color(red: 245/255, green: 246/255, blue: 250/255)
        } else if state == .done {
            return Color(red: 220/255, green: 221/255, blue: 225/255)
        } else {
            return Color.primary
        }
    }
}
