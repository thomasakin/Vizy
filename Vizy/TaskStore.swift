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

class TaskStore: ObservableObject {
    @Published var tasks: [CoreDataTask] = []
    @Published var selectedImage: IdentifiableImage?
    @Published var isCreatingNewTask: Bool = false
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
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

    func createTask(withPhotoData photoData: Data) {
        let newTask = CoreDataTask(context: context)
        newTask.id = UUID()
        newTask.photoData = photoData
        newTask.stateRaw = TaskState.new.rawValue
        newTask.dueDate = Date()
        newTask.note = ""
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
