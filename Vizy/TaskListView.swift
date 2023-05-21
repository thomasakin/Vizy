//
//  TaskListView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskStore: TaskStore
    
    @State private var selectedPageIndex = 0
    
    private let pageTitles = ["All Tasks", "New Tasks", "Doing Tasks", "Done Tasks"]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $selectedPageIndex, label: Text("Page")) {
                    ForEach(0..<pageTitles.count, id: \.self) { index in
                        Text(pageTitles[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedPageIndex) {
                    ForEach(0..<pageTitles.count, id: \.self) { index in
                        TaskListPageView(title: pageTitles[index], tasks: filteredTasks(for: index))
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(pageTitles[selectedPageIndex])
            .navigationBarItems(trailing: NavigationLink(destination: NewTaskView()) {
                Image(systemName: "plus")
            })
        }
    }
    
    private func filteredTasks(for pageIndex: Int) -> [Task] {
        let allTasks = taskStore.tasks
        
        switch pageIndex {
        case 0:
            return sortTasks(allTasks)
        case 1:
            let newTasks = allTasks.filter { $0.state == .new }
            return sortTasks(newTasks)
        case 2:
            let doingTasks = allTasks.filter { $0.state == .doing }
            return sortTasks(doingTasks)
        case 3:
            let doneTasks = allTasks.filter { $0.state == .done }
            return sortTasks(doneTasks)
        default:
            return []
        }
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        return tasks.sorted { (task1, task2) -> Bool in
            if task1.state == task2.state {
                return task1.dueDate < task2.dueDate
            } else {
                return task1.state < task2.state
            }
        }
    }

}

struct TaskListPageView: View {
    let title: String
    let tasks: [Task]
    
    var body: some View {
        List(tasks, id: \.id) { task in
            NavigationLink(destination: TaskDetailsView(task: task)) {
                TaskRow(task: task)
                    .foregroundColor(rowColor(for: task))
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private let doneTaskColor = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00) // #dcdde1
    
    private func rowColor(for task: Task) -> Color {
        if task.state == .done {
            if task.dueDate < Date() {
                return Color(doneTaskColor)
            } else {
                return Color(red: 25/255, green: 42/255, blue: 86/255) // Text color for done tasks
            }
        } else {
            return Color.primary
        }
    }
}
