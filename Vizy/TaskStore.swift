//
//  TaskStore.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//
import Foundation
import CoreData
import Combine
import SwiftUI

class NavigationState: ObservableObject {
    @Published var selectedTask: CoreDataTask?
}

class TaskStore: ObservableObject {
    @Published var tasks: [CoreDataTask] = []
    @Published var selectedImage: IdentifiableImage?
    @Published var isCreatingNewTask: Bool = false
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTasks()
    }

    func deleteTask(_ task: CoreDataTask) {
        context.delete(task)
        saveContext()
        fetchTasks()
    }
    
    func fetchTasks() {
        let request: NSFetchRequest<CoreDataTask> = CoreDataTask.fetchRequest()
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }

    // We don't currently use name
    func createTask(name: String, note: String, dueDate: Date, state: TaskState, photoData: Data) {
        let newTask = CoreDataTask(context: context)
        newTask.id = UUID()
        newTask.photoData = photoData
        newTask.dueDate = dueDate
        newTask.note = note
        newTask.name = name
        newTask.stateRaw = state.rawValue

        do {
            try context.save()
            fetchTasks()  // Fetch tasks again to include the new task
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        isCreatingNewTask = true
    }
    
    func createDefaultTask() {
        let newTask = CoreDataTask(context: context)
        let imageData = selectedImage?.uiImage.jpegData(compressionQuality: 1.0) ?? UIImage.defaultImage.jpegData(compressionQuality: 1.0)
        let state: TaskState = .todo
        newTask.id = UUID()
        newTask.photoData = imageData
        newTask.dueDate = Date()
        newTask.note = ""
        newTask.name = ""
        newTask.stateRaw = state.rawValue

        do {
            try context.save()
            fetchTasks()  // Fetch tasks again to include the new task
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        isCreatingNewTask = true
    }
    
    
    func toggleState(forTask task: CoreDataTask) {
        guard let currentState = TaskState(rawValue: task.stateRaw ?? "") else {
            return
        }
        switch currentState {
        case .todo:
            task.stateRaw = TaskState.doing.rawValue
        case .doing:
            task.stateRaw = TaskState.done.rawValue
        case .done:
            task.stateRaw = TaskState.todo.rawValue
        }
        saveContext()
        fetchTasks()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}
