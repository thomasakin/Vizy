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
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var taskStore = TaskStore(context: PersistenceController.shared.container.viewContext)
    @StateObject private var settings = Settings()
    @State private var showNewTaskView = false
    @State private var showCameraView = false
    @State private var isShowingImagePicker = false
    @State private var isCameraAuthorized = CameraAuthorization.isCameraAuthorized
    //@StateObject private var taskStore: TaskStore
    @Environment(\.managedObjectContext) var managedObjectContext

    init() {
        let context = PersistenceController.shared.container.viewContext
        _taskStore = StateObject(wrappedValue: TaskStore(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            let _ = print("VizyApp->TaskListView")
            TaskListView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(NavigationState())  // Provide NavigationState to all child views
                .environmentObject(settings) // Provide Settings to all child views
                .environmentObject(taskStore)
                .sheet(isPresented: $isShowingImagePicker) {
                    CameraView(identifiableImage: $taskStore.selectedImage, taskStore: taskStore)
                        .edgesIgnoringSafeArea(.all)
                }
                .sheet(isPresented: $taskStore.isCreatingNewTask) {
                    NewTaskView(image: nil, isCreatingNewTask: $taskStore.isCreatingNewTask, taskStore: taskStore, context: managedObjectContext)
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
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
        let _ = print("TLV: End")
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    //var persistentContainer: NSPersistentContainer!

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        persistentContainer = NSPersistentContainer(name: "Vizy")
//        persistentContainer.loadPersistentStores { (storeDescription, error) in
//            if let error = error {
//                fatalError("Unresolved error \(error)")
//            }
//        }
//        return true
//    }

    let contentView = TaskListView()
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func saveContext() {
        let context = PersistenceController.shared.container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let shortcutType = shortcutItem.type.components(separatedBy: ".").last else {
            completionHandler(false)
            return
        }

        switch shortcutType {
        case "newtask":
            if let window = windowScene.windows.first,
               let rootView = window.rootViewController as? UIHostingController<TaskListView> {
                rootView.rootView.taskStore.isCreatingNewTask = true
            }
        case "phototask":
            if let window = windowScene.windows.first,
               let rootView = window.rootViewController as? UIHostingController<TaskListView> {
                rootView.rootView.isShowingCameraView = true
            }
        default:
            completionHandler(false)
            return
        }

        completionHandler(true)
    }
    
}
