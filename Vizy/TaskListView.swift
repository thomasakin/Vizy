//
//  TaskListView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData
import Foundation
import AVFoundation

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: CoreDataTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CoreDataTask.dueDate, ascending: true)]
    ) private var tasks: FetchedResults<CoreDataTask>
    
    @State private var isShowingSettings = false

    @State private var selectedPageIndex = 0
    @State private var searchText = ""
    @State private var isShowingImagePicker = false
    @State private var isCameraAuthorized = false
    
    var containerWidth:CGFloat = UIScreen.main.bounds.width - 32.0

    private let pageTitles = ["Todo", "Doing", "Done", "All"]

    @StateObject var taskStore = TaskStore(context: PersistenceController.shared.container.viewContext)

    private var filteredTasks: [CoreDataTask] {
        let lowercaseSearchText = searchText.lowercased()
        switch selectedPageIndex {
        case 0:
            return filterTasks(withState: "todo", searchText: lowercaseSearchText)
        case 1:
            return filterTasks(withState: "doing", searchText: lowercaseSearchText)
        case 2:
            return filterTasks(withState: "done", searchText: lowercaseSearchText)
        case 3:
            if lowercaseSearchText.isEmpty {
                return sortTasks(tasks.map { $0 })
            } else {
                return sortTasks(tasks.map { $0 }).filter { task in
                    let formattedDueDate = task.dueDate != nil ? TaskListView.dateFormatter.string(from: task.dueDate!) : ""
                    let lowercaseNote = task.note?.lowercased() ?? ""

                    return lowercaseNote.contains(lowercaseSearchText) || formattedDueDate.contains(lowercaseSearchText)
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
            ZStack(alignment: .top) {
                VStack {
                    //TextField("Search tasks...", text: $searchText)
                    //    .padding(.horizontal)
                    //    .overlay(
                    //        Group {
                    //            if !searchText.isEmpty {
                    //                Button(action: {
                    //                    searchText = ""
                    //                }) {
                    //                    Image(systemName: "xmark.circle.fill")
                    //                        .foregroundColor(.gray)
                    //                        .padding(.trailing, 8)
                    //                }
                    //            }
                    //        }, alignment: .trailing
                    //    )
                    //    .background(Color.white.edgesIgnoringSafeArea(.all))

                    Picker(selection: $selectedPageIndex, label: Text("Page")) {
                        ForEach(0..<pageTitles.count, id: \.self) { index in
                            Text(pageTitles[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.white.edgesIgnoringSafeArea(.all))

                    TabView(selection: $selectedPageIndex) {
                        ForEach(0..<pageTitles.count, id: \.self) { index in
                            TaskListPageView(
                                title: pageTitles[index],
                                taskStore: taskStore,
                                searchText: $searchText,
                                pageIndex: index
                            )
                            .environment(\.managedObjectContext, viewContext)
                            .tag(index)
                        }
                    }
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    VStack {
                        Button(action: {
                            self.isShowingSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                        }
                        .sheet(isPresented: $isShowingSettings) {
                            SettingsView()
                        }
                    }
                }
                .background(Color.white.edgesIgnoringSafeArea(.all))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(pageTitles[selectedPageIndex])
            //.navigationBarItems(leading: cameraButton, trailing: addButton)
            .navigationBarItems(leading: searchBar, trailing: HStack {addButton; cameraButton} )
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

    private func cellColor(for state: TaskState) -> Color {
        switch state {
        case .todo:
            return Color.paleGreenColor
        case .doing:
            return Color.softYellowColor
        case .done:
            return Color.doneTaskColor
        }
    }
    
    private var searchBar: some View {
        TextField("Search tasks...", text: $searchText)
            .frame(width:containerWidth * 0.33)
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
            .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    private var cameraButton: some View {
        Button(action: {
            isShowingImagePicker = true
        }) {
            Image(systemName: "camera")
        }
    }

    private var addButton: some View {
        NavigationLink(destination: NewTaskView(image: nil, isCreatingNewTask: $taskStore.isCreatingNewTask)) {
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

    private func dueDateColor(for date: Date, state: TaskState) -> Color {
        let today = Calendar.current.startOfDay(for: Date())
        let dueDate = Calendar.current.startOfDay(for: date)

        if dueDate < today && state != .done {
            return Color(red: 194/255, green: 54/255, blue: 22/255).opacity(0.65)
        } else if Calendar.current.isDateInToday(dueDate) {
            return Color(red: 156/255, green: 136/255, blue: 255/255).opacity(0.65)
        } else if dueDate > today {
            return Color(red: 245/255, green: 246/255, blue: 250/255).opacity(0.65)
        } else if state == .done {
            return Color(red: 220/255, green: 221/255, blue: 225/255).opacity(0.65)
        } else {
            return Color.primary.opacity(0.65)
        }
    }

    private func sortTasks(_ tasks: [CoreDataTask]) -> [CoreDataTask] {
        return tasks.sorted { (task1, task2) -> Bool in
            guard let dueDate1 = task1.dueDate else { return false }
            guard let dueDate2 = task2.dueDate else { return true }
            return dueDate1 < dueDate2
        }
    }
    
    private func filterTasks(withState state: String, searchText: String) -> [CoreDataTask] {
        if searchText.isEmpty {
            return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == state })
        } else {
            return sortTasks(tasks.filter { ($0.stateRaw?.lowercased() ?? "") == state }).filter { task in
                let lowercaseNote = task.note?.lowercased() ?? ""

                return lowercaseNote.contains(searchText)
            }
        }
    }
}
