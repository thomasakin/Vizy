//
//  EditTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import UIKit

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: CoreDataTask

    @State private var isShowingImagePicker = false
    @State private var identifiableImage: IdentifiableImage?

    init(task: CoreDataTask) {
        self.task = task
        if let data = task.photoData, let uiImage = UIImage(data: data) {
            self._identifiableImage = State(initialValue: IdentifiableImage(uiImage: uiImage))
        } else {
            self._identifiableImage = State(initialValue: nil)
        }
    }

    var body: some View {
        VStack {
            if let identifiableImage = identifiableImage {
                Image(uiImage: identifiableImage.uiImage)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        self.isShowingImagePicker = true
                    }
            } else {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        self.isShowingImagePicker = true
                    }
            }

            Picker("State", selection: Binding(
                get: { TaskState(rawValue: self.task.stateRaw ?? "") ?? .todo },
                set: { newValue in self.task.stateRaw = newValue.rawValue }
            )) {
                ForEach(TaskState.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }

            DatePicker("Due Date",
                       selection: Binding(
                            get: { self.task.dueDate ?? Date() },
                            set: { self.task.dueDate = $0 }
                        ),
                       displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
            
            TextField("Title", text: Binding(
                get: { self.task.name ?? "" },
                set: { self.task.name = $0 }
            ))
            Spacer()
            TextField("Notes", text: Binding(
                get: { self.task.note ?? "" },
                set: { self.task.note = $0 }
            ))

            Button("Save Task") {
                if let identifiableImage = identifiableImage {
                    if let imageData = identifiableImage.uiImage.jpegData(compressionQuality: 1.0) {
                        task.photoData = imageData
                    }
                }
                saveContext()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: self.$identifiableImage, onImageSelected: self.onImageSelected)
        }
    }
    
    func onImageSelected(_ imageData: Data) {
        // You can leave this empty or add any actions you want to perform when an image is selected
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
