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
                    NavigationLink(destination: TaskDetailsView(task: task).environmentObject(taskStore)) {
                        TaskRow(task: task)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        taskStore.deleteTask(at: index)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarItems(trailing: NavigationLink(destination: NewTaskView()) {
                Image(systemName: "plus")
            })
        }
    }
}
