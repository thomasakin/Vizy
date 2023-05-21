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
    @State private var searchText = ""
    
    private let pageTitles = ["All Tasks", "New Tasks", "Doing Tasks", "Done Tasks"]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search tasks...", text: $searchText)
                    .padding(.horizontal)
                    .overlay(
                        Group {
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }, alignment: .trailing
                    )
                Picker(selection: $selectedPageIndex, label: Text("Page")) {
                    ForEach(0..<pageTitles.count, id: \.self) { index in
                        Text(pageTitles[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedPageIndex) {
                    ForEach(0..<pageTitles.count, id: \.self) { index in
                        TaskListPageView(title: pageTitles[index], tasks: taskStore.tasks, searchText: $searchText, pageIndex: index, filterTasks: filteredTasks)
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
    
    func filteredTasks(for pageIndex: Int, searchText: String, tasks: [Task]) -> [Task] {
        var tasks = [Task]()

        switch pageIndex {
        case 0:
            tasks = self.taskStore.tasks
        case 1:
            tasks = self.taskStore.tasks.filter { $0.state == .new }
        case 2:
            tasks = self.taskStore.tasks.filter { $0.state == .doing }
        case 3:
            tasks = self.taskStore.tasks.filter { $0.state == .done }
        default:
            tasks = []
        }

        if !searchText.isEmpty {
            let lowercasedSearchText = searchText.lowercased()
            tasks = tasks.filter { task in
                let formattedDueDate = Self.dateFormatter.string(from: task.dueDate).lowercased()
                return task.notes.lowercased().contains(lowercasedSearchText)
                    || formattedDueDate.contains(lowercasedSearchText)
            }
        }

        return sortTasks(tasks)
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
    @Binding var searchText: String
    let pageIndex: Int
    let filterTasks: (Int, String, [Task]) -> [Task]
    
    private let doneTaskColor = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00) // #dcdde1
    
    @EnvironmentObject var taskStore: TaskStore // add this line
    
    var filteredTasks: [Task] {
        return filterTasks(pageIndex, searchText, tasks)
    }

    var body: some View {
        List(filteredTasks, id: \.id) { task in
            NavigationLink(destination: TaskDetailsView(task: task)) {
                TaskRow(task: task)
            }

        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func rowColor(for task: Task) -> Color {
        if task.state == .done {
            if task.isOverdue {
                return .red
            } else {
                return Color(doneTaskColor)
            }
        } else {
            if task.isOverdue {
                return .red
            } else {
                return .black
            }
        }
    }
}
