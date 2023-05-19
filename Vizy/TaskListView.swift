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
                ForEach(Array(taskStore.tasks.enumerated()), id: \.element.id) { index, task in
                    NavigationLink(destination: TaskDetailsView(index: index).environmentObject(taskStore)) {
                        TaskRow(task: task)
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
