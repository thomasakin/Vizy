//
//  VizyApp.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData
import Foundation
import AVFoundation

@main
struct VizyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //@StateObject private var taskStore = TaskStore(context: PersistenceController.shared.container.viewContext)
    @StateObject private var settings = Settings()
    @State private var showNewTaskView = false
    @State private var showCameraView = false
    @State private var isShowingImagePicker = false
    @State private var isCameraAuthorized = CameraAuthorization.isCameraAuthorized
    @StateObject private var taskStore: TaskStore

    init() {
        let context = PersistenceController.shared.container.viewContext
        _taskStore = StateObject(wrappedValue: TaskStore(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
                .environmentObject(NavigationState())  // Provide NavigationState to all child views
                .environmentObject(settings) // Provide Settings to all child views
                .environmentObject(taskStore)
                .sheet(isPresented: $isShowingImagePicker) {
                    CameraView(identifiableImage: $taskStore.selectedImage, taskStore: taskStore)
                        .edgesIgnoringSafeArea(.all)
                }
                .sheet(isPresented: $taskStore.isCreatingNewTask) {
                    NewTaskView(image: taskStore.selectedImage, isCreatingNewTask: $taskStore.isCreatingNewTask, taskStore: taskStore)
                        .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
                }
                .onAppear {
                    CameraAuthorization.checkCameraAuthorizationStatus()
                    isCameraAuthorized = CameraAuthorization.isCameraAuthorized
                }

        }
        .commands {
            CommandMenu("Tasks") {
                Button("New Task") {
                    showNewTaskView = true
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Camera View") {
                    showCameraView = true
                }
                .keyboardShortcut("c", modifiers: .command)
            }
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
