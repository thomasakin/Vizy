//
//  TaskDetailsView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct TaskDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore
    @ObservedObject var task: Task

    var body: some View {
        VStack {
            Image(uiImage: task.photo.uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(task.state.rawValue)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(statusColor(for: task.state))
                .onTapGesture {
                    task.toggleState()
                }
            Text(task.dueDate, style: .date)
                .strikethrough(task.state == .done)
                .foregroundColor(dueDateColor(for: task.dueDate))
            Text(task.notes)

            Spacer()

            Button(action: {
                if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                    taskStore.deleteTask(at: index)
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Delete")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: NavigationLink(destination: EditTaskView(task: task)) {
            Text("Edit")
        })
        .onChange(of: task.state) { newState in
            if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                taskStore.updateTask(task, at: index)
            }
        }
        .onChange(of: task.dueDate) { newDueDate in
            if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                taskStore.updateTask(task, at: index)
            }
        }
    }

    private func statusColor(for state: TaskState) -> Color {
        switch state {
        case .new:
            return Color(paleGreenColor)
        case .doing:
            return Color(softYellowColor)
        case .done:
            return Color(doneTaskColor)
        }
    }

    private let doneTaskColor = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00) // #dcdde1

    private func dueDateColor(for date: Date) -> Color {
        let today = Calendar.current.startOfDay(for: Date())
        let dueDate = Calendar.current.startOfDay(for: date)
        let pastDueColor = UIColor(red: 194/255, green: 54/255, blue: 22/255, alpha: 1.00) // #c23616

        if dueDate < today && task.state != .done {
            return Color(pastDueColor)
        } else if Calendar.current.isDateInToday(dueDate) {
            return Color(UIColor(red: 0/255, green: 168/255, blue: 255/255, alpha: 1.00)) // #00a8ff
        } else if dueDate > today {
            return Color(red: 113/255, green: 128/255, blue: 147/255)
        } else {
            return Color(doneTaskColor)
        }
    }

    private let paleGreenColor = UIColor(red: 0.30, green: 0.82, blue: 0.22, alpha: 1.00)
    private let softYellowColor = UIColor(red: 0.98, green: 0.77, blue: 0.19, alpha: 1.00)
    private let paleLavenderColor = UIColor(red: 0.61, green: 0.53, blue: 1.00, alpha: 1.00)
}
