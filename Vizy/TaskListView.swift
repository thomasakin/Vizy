//
//  TaskListView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData
import AVFoundation

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: CoreDataTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CoreDataTask.dueDate, ascending: true)]
    ) private var tasks: FetchedResults<CoreDataTask>
    
    @State private var selectedPageIndex = 1
    @State private var searchText = ""
    @State private var isShowingImagePicker = false
    @State private var isCameraAuthorized = false
    
    private let pageTitles = ["All", "New", "Doing", "Done"]
    
    @StateObject private var taskStore: TaskStore
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _taskStore = StateObject(wrappedValue: TaskStore(context: context))
    }
    
    private var filteredTasks: [CoreDataTask] {
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

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

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
                            tasks: filteredTasks,
                            searchText: $searchText,
                            pageIndex: index
                        )
                        .environment(\.managedObjectContext, viewContext)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(pageTitles[selectedPageIndex])
            .navigationBarItems(leading: cameraButton, trailing: addButton)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            CameraView(identifiableImage: $taskStore.selectedImage, taskStore: taskStore)
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $taskStore.isCreatingNewTask) {
            NewTaskView(image: taskStore.selectedImage, isCreatingNewTask: $taskStore.isCreatingNewTask)
            .environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            checkCameraAuthorizationStatus()
        }
    }
    
    private var cameraButton: some View {
        Button(action: {
            isShowingImagePicker = true
        }) {
            Image(systemName: "camera")
        }
    }
    
    private var addButton: some View {
        NavigationLink(destination: NewTaskView(image: taskStore.selectedImage, isCreatingNewTask: $taskStore.isCreatingNewTask)) {
            Image(systemName: "plus")
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
    
    private func showCameraSettingsAlert() {
        let alert = UIAlertController(
            title: "Camera Access",
            message: "Please allow camera access in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    private func sortTasks(_ tasks: [CoreDataTask]) -> [CoreDataTask] {
        return tasks.sorted { (task1, task2) -> Bool in
            guard let dueDate1 = task1.dueDate else { return false }
            guard let dueDate2 = task2.dueDate else { return true }
            return dueDate1 < dueDate2
        }
    }
}
