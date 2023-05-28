//
//  TaskDetailsView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI
import CoreData

struct TaskDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: CoreDataTask

    // Add this state variable to handle image fullscreen view
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
            }
            
            Text(TaskState(rawValue: task.stateRaw ?? "")?.rawValue ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(statusColor(for: TaskState(rawValue: task.stateRaw ?? "") ?? .new))
                .onTapGesture {
                    task.toggleState()
                    saveContext()
                }
            Text(task.dueDate ?? Date(), style: .date)
                .strikethrough(TaskState(rawValue: task.stateRaw ?? "") == .done)
                .foregroundColor(dueDateColor(for: task.dueDate ?? Date()))
            Text(task.note ?? "")

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
        .padding()
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: NavigationLink(destination: EditTaskView(task: task)) {
            Text("Edit")
        })
    }

    private func statusColor(for state: TaskState) -> Color {
        switch state {
        case .new:
            return Color(paleGreenColor)
        case .doing:
            return Color(softYellowColor)
        case .done:
            return Color(doneTaskColor)
        }
    }

    private let doneTaskColor = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00) // #dcdde1

    private func dueDateColor(for date: Date) -> Color {
        let today = Calendar.current.startOfDay(for: Date())
        let dueDate = Calendar.current.startOfDay(for: date)
        let pastDueColor = UIColor(red: 194/255, green: 54/255, blue: 22/255, alpha: 1.00) // #c23616

        if dueDate < today && TaskState(rawValue: task.stateRaw ?? "") != .done {
            return Color(pastDueColor)
        } else if Calendar.current.isDateInToday(dueDate) {
            return Color(UIColor(red: 0/255, green: 168/255, blue: 255/255, alpha: 1.00)) // #00a8ff
        } else if dueDate > today {
            return Color(red: 113/255, green: 128/255, blue: 147/255)
        } else {
            return Color(doneTaskColor)
        }
    }

    private let paleGreenColor = UIColor(red: 0.30, green: 0.82, blue: 0.22, alpha: 1.00)
    private let softYellowColor = UIColor(red: 0.98, green: 0.77, blue: 0.19, alpha: 1.00)
    private let paleLavenderColor = UIColor(red: 0.61, green: 0.53, blue: 1.00, alpha: 1.00)

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
