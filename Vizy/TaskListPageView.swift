//
//  TaskListPageView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

//Calling
// TaskListPageView(
//    title: pageTitles[index],
//    tasks: filteredTasks,
//    searchText: $searchText,
//    pageIndex: index)

struct TaskListPageView: View {
    let title: String
    let tasks: [CoreDataTask]
    @Binding var searchText: String
    let pageIndex: Int


    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(), count: 3)) {
                ForEach(filteredTasks) { task in
                    NavigationLink(destination: TaskDetailsView(task: task)) {
                        TaskCard(task: task)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(title)
    }

    private var filteredTasks: [CoreDataTask] {
        tasks.filter { task in
            (pageIndex == 3 || task.stateRaw == TaskState.allCases[pageIndex].rawValue) &&
            (searchText.isEmpty || task.note?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        .sorted(by: { $0.dueDate ?? Date() < $1.dueDate ?? Date() })
    }
}
