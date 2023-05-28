//
//  TaskListView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: CoreDataTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CoreDataTask.dueDate, ascending: true)]
    ) var tasks: FetchedResults<CoreDataTask>
    
    @State private var selectedPageIndex = 1
    @State private var searchText = ""
    
    private let pageTitles = ["All", "New", "Doing", "Done"]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var filteredTasks: [CoreDataTask] {
        let lowercaseSearchText = searchText.lowercased()
        switch selectedPageIndex {
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
                        TaskListPageView(
                            title: pageTitles[index],
                            tasks: tasks,
                            searchText: $searchText,
                            pageIndex: index,
                            viewContext: managedObjectContext // Pass the viewContext
                        )
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
}

private func sortTasks(_ tasks: [CoreDataTask]) -> [CoreDataTask] {
    return tasks.sorted { (task1, task2) -> Bool in
        guard let dueDate1 = task1.dueDate else { return false }
        guard let dueDate2 = task2.dueDate else { return true }
        return dueDate1 < dueDate2
    }
}

struct TaskListPageView: View {
    let title: String
    let tasks: FetchedResults<CoreDataTask>
    @Binding var searchText: String
    let pageIndex: Int
    let viewContext: NSManagedObjectContext // Added viewContext
    
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
            NavigationLink(destination: TaskDetailsView(task: task).environment(\.managedObjectContext, viewContext)) {
                TaskRow(task: task)
                    .onTapGesture {
                        task.toggleState()
                        saveContext()
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
