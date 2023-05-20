//
//  TaskDetailsView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct TaskDetailsView: View {
    @EnvironmentObject var taskStore: TaskStore
    var index: Int

    var body: some View {
        let task = taskStore.tasks[index]
        VStack {
            if let image = task.photo {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(task.dueDate, style: .date)
            Text(task.notes ?? "")
        }
        .padding()
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: NavigationLink(destination: EditTaskView(index: index, task: <#Task#>).environmentObject(taskStore)) {
            Text("Edit")
        })
    }
}
