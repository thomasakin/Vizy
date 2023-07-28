//
//  TaskListPageView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct TaskListPageView: View {
    @EnvironmentObject var navigationState: NavigationState
    let title: String
    let tasks: [CoreDataTask]
    @Binding var searchText: String
    let pageIndex: Int

    private let statusColors: [TaskState: Color] = [
        .todo: Color(#colorLiteral(red: 0.2666666667, green: 0.7411764706, blue: 0.1960784314, alpha: 1)),
        .doing: Color(#colorLiteral(red: 0.9843137255, green: 0.7725490196, blue: 0.1921568627, alpha: 1)),
        .done: Color(#colorLiteral(red: 0.5490196078, green: 0.4862745098, blue: 0.9019607843, alpha: 1))
    ]

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
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "todo" })
            } else {
                return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == "todo" }).filter { task in
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
        List(groupTasksIntoTwos(tasks: filteredTasks), id: \.self) { tasks in
            GroupedTasksRow(tasks: tasks)
        }
        .listStyle(InsetGroupedListStyle())
    }

    private func groupTasksIntoTwos(tasks: [CoreDataTask]) -> [[CoreDataTask]] {
        return stride(from: 0, to: tasks.count, by: 2).map {
            Array(tasks[$0..<min($0.advanced(by: 2), tasks.count)])
        }
    }

    private func sortTasks(_ tasks: [CoreDataTask]) -> [CoreDataTask] {
        return tasks.sorted { (task1, task2) -> Bool in
            guard let dueDate1 = task1.dueDate else { return false }
            guard let dueDate2 = task2.dueDate else { return true }
            return dueDate1 < dueDate2
        }
    }

    private func statusColor(for state: TaskState) -> Color {
        return statusColors[state] ?? .primary
    }
}
