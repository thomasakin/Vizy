//
//  EditTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI
import UIKit

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    var index: Int
    @EnvironmentObject var taskStore: TaskStore
    @State private var isShowingImagePicker = false
    @State private var identifiableImage: IdentifiableImage? // Changed this from UIImage to IdentifiableImage
    @State private var notes: String
    @State private var date: Date

    init(index: Int, task: Task) {
        self.index = index
        self._identifiableImage = State(initialValue: task.photo) // Changed this from uiImage to identifiableImage
        self._notes = State(initialValue: task.notes)
        self._date = State(initialValue: task.dueDate)
    }

    var body: some View {
        VStack {
            if let identifiableImage = identifiableImage {
                Image(uiImage: identifiableImage.uiImage) // Use the uiImage property of IdentifiableImage
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

            DatePicker("Due Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())

            TextField("Notes", text: $notes)

            Button("Save Task") {
                let task = Task(photo: identifiableImage?.uiImage ?? taskStore.tasks[index].photo.uiImage, dueDate: date, notes: notes)
                taskStore.tasks[index] = task
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(identifiableImage == nil)
        }
        .padding()
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: self.$identifiableImage)
        }
    }
}
