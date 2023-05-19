//
//  TasksView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskStore: TaskStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskStore.tasks.indices, id: \.self) { index in
                    NavigationLink(destination: EditTaskView(index: index).environmentObject(taskStore)) {
                        TaskRow(task: taskStore.tasks[index])
                    }
                }
            }
            .navigationBarTitle("Tasks")
            .navigationBarItems(trailing: NavigationLink(destination: NewTaskView().environmentObject(taskStore)) {
                Image(systemName: "plus")
            })
        }
    }
}
