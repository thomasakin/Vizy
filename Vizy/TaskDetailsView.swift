//
//  TaskDetailsView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct TaskDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: CoreDataTask
    @ObservedObject var taskStore: TaskStore
    
    @State private var isShowingImageFullScreen = false
    
    var body: some View {
        VStack {
            if let data = task.photoData, let uiImage = UIImage(data: data) {
                let identifiableImage = IdentifiableImage(uiImage: uiImage)
                Image(uiImage: identifiableImage.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        isShowingImageFullScreen = true
                    }
                    .fullScreenCover(isPresented: $isShowingImageFullScreen) {
                        Image(uiImage: identifiableImage.uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isShowingImageFullScreen = false
                            }
                    }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
            
            Text(TaskState(rawValue: task.stateRaw ?? "")?.rawValue ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(statusColor(for: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                //.onLongPressGesture {
                //    taskStore.toggleState(forTask: task)
                //    saveContext()
                //}
            Text(task.dueDate ?? Date(), style: .date)
                .strikethrough(TaskState(rawValue: task.stateRaw ?? "") == .done)
                .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
            VStack {
                Text(task.name ?? "")
                Text(task.note ?? "")
            }
            Spacer()

            Button(action: {
                viewContext.delete(task)
                saveContext()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Delete")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationTitle("Task Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EditTaskView(task: task)) {
                    Text("Edit")
                }
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
    
    private func statusColor(for state: TaskState) -> Color {
        switch state {
        case .todo:
            return Color(red: 68/255, green: 189/255, blue: 50/255)
        case .doing:
            return Color(red: 251/255, green: 197/255, blue: 49/255)
        case .done:
            return Color(red: 140/255, green: 122/255, blue: 230/255)
        }
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
