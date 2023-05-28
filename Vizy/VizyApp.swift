//
//  VizyApp.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

@main
struct VizyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var persistentContainer: NSPersistentContainer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        persistentContainer = NSPersistentContainer(name: "Vizy")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
