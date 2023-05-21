//
//  TaskListView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskStore: TaskStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskStore.tasks, id: \.id) { task in
                    NavigationLink(destination: TaskDetailsView(index: taskStore.tasks.firstIndex(where: { $0.id == task.id })!).environmentObject(taskStore)) {
                        TaskRow(task: task)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarItems(trailing: NavigationLink(destination: NewTaskView()) {
                Image(systemName: "plus")
            })
        }
        .id(taskStore.tasks) // Add this line
    }
}
