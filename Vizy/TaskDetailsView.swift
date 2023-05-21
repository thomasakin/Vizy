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
    }

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

    private let paleGreenColor = UIColor(red: 0.725, green: 0.894, blue: 0.737, alpha: 1.0)
    private let softYellowColor = UIColor(red: 0.953, green: 0.925, blue: 0.682, alpha: 1.0)
    private let paleLavenderColor = UIColor(red: 0.839, green: 0.796, blue: 0.925, alpha: 1.0)
}
