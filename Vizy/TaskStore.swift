//
//  TaskStore.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//
import Foundation
import CoreData
import CloudKit

class TaskStore: ObservableObject {
    @Published var tasks = [CoreDataTask]()
    
    let container: NSPersistentCloudKitContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentCloudKitContainer(name: "CoreDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        context = container.viewContext
        
        // Fetch data on initialization
        self.fetchTasks()
    }
    
    private func fetchTasks() {
        let fetchRequest: NSFetchRequest<CoreDataTask> = CoreDataTask.fetchRequest()
        do {
            let taskEntities = try context.fetch(fetchRequest)
            self.tasks = taskEntities
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func addTask(_ task: CoreDataTask) {
        do {
            try context.save()
            tasks.append(task)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func updateTask(_ task: CoreDataTask, at index: Int) {
        guard let id = task.id else { return }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CoreDataTask.fetchRequest()
        if let id = task.id {
            fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        }
        do {
            if let result = try context.fetch(fetchRequest).first as? CoreDataTask {
                try context.save()
                tasks[index] = result
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func deleteTask(at index: Int) {
        guard let id = tasks[index].id else { return }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CoreDataTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        do {
            if let result = try context.fetch(fetchRequest).first as? CoreDataTask {
                context.delete(result)
                try context.save()
                tasks.remove(at: index)
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
