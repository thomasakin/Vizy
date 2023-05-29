//
//  TaskListPageView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct TaskListPageView: View {
    let title: String
    let tasks: [CoreDataTask]
    @Binding var searchText: String
    let pageIndex: Int
    
    var filteredTasks: [CoreDataTask] {
        let lowercaseSearchText = searchText.lowercased()
        switch pageIndex {
        case 0:
            if lowercaseSearchText.isEmpty {
                return sortTasks(tasks.map { $0 })
            } else {
                return sortTasks(tasks.map { $0 }).filter { task in
                    let formattedDueDate = task.dueDate != nil ? TaskListView.dateFormatter.string(from: task.dueDate!) : ""
                    let lowercaseNote = task.note?.lowercased() ?? ""
                    
                    return lowercaseNote.contains(lowercaseSearchText) || formattedDueDate.contains(lowercaseSearchText)
                }
            }
        case 1:
            if lowercaseSearchText.isEmpty {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "new" })
            } else {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "new" }).filter { task in
                    let lowercaseNote = task.note?.lowercased() ?? ""
                    
                    return lowercaseNote.contains(lowercaseSearchText)
                }
            }
        case 2:
            if lowercaseSearchText.isEmpty {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "doing" })
            } else {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "doing" }).filter { task in
                    let lowercaseNote = task.note?.lowercased() ?? ""
                    
                    return lowercaseNote.contains(lowercaseSearchText)
                }
            }
        case 3:
            if lowercaseSearchText.isEmpty {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "done" })
            } else {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "done" }).filter { task in
                    let lowercaseNote = task.note?.lowercased() ?? ""
                    
                    return lowercaseNote.contains(lowercaseSearchText)
                }
            }
        default:
            return []
        }
    }

    var body: some View {
        List(filteredTasks, id: \.id) { task in
            NavigationLink(destination: TaskDetailsView(task: task)) {
                TaskRow(task: task)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func sortTasks(_ tasks: [CoreDataTask]) -> [CoreDataTask] {
        return tasks.sorted { (task1, task2) -> Bool in
            guard let dueDate1 = task1.dueDate else { return false }
            guard let dueDate2 = task2.dueDate else { return true }
            return dueDate1 < dueDate2
        }
    }
}
