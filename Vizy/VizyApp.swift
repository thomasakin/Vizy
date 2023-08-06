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
    @StateObject var taskStore = TaskStore // Initialize TaskStore at the app level
    @StateObject private var settings = Settings()
    @State private var showNewTaskView = false
    @State private var showCameraView = false
    @State private var isShowingImagePicker = false
    @State private var isCameraAuthorized = false
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(taskStore) 
                .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
                .environmentObject(NavigationState())  // Provide NavigationState to all child views
                .environmentObject(settings) // Provide Settings to all child views
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
        .sheet(isPresented: $isShowingImagePicker) {
            CameraView(identifiableImage: $taskStore.selectedImage, taskStore: taskStore)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $taskStore.isCreatingNewTask) {
            NewTaskView(image: taskStore.selectedImage, isCreatingNewTask: $taskStore.isCreatingNewTask, taskStore: taskStore)
                .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
        }
        .onAppear {
            checkCameraAuthorizationStatus()
        }
    }
}

private func checkCameraAuthorizationStatus() {
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    switch cameraAuthorizationStatus {
    case .notDetermined:
        requestCameraAuthorization()
    case .authorized:
        isCameraAuthorized = true
    case .restricted, .denied:
        isCameraAuthorized = false
    @unknown default:
        isCameraAuthorized = false
    }
}

private func requestCameraAuthorization() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
            self.isCameraAuthorized = granted
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
