//
//  DefaultNewTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 8/11/23.
//

import Foundation
import SwiftUI
import CoreData

struct DefaultNewTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            Text("Creating default task...")
        }
        .onAppear {
            createDefaultTask()
        }
    }

    private func createDefaultTask() {
        let task = CoreDataTask(context: viewContext)
        task.id = UUID()
        task.stateRaw = TaskState.todo.rawValue
        task.dueDate = Date()
        task.note = ""

        if let defaultImageData = UIImage.defaultImage.jpegData(compressionQuality: 1.0) {
            task.photoData = defaultImageData
        }

        do {
            try viewContext.save()
            navigateToEditTaskView(task: task)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func navigateToEditTaskView(task: CoreDataTask) {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Code to navigate to EditTaskView with the newly created task
        }
    }
}
