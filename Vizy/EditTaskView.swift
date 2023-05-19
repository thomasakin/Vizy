//
//  EditTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    var index: Int
    @EnvironmentObject var taskStore: TaskStore
    
    @State private var isShowingImagePicker = false
    @State private var uiImage: UIImage?
    @State private var notes = ""
    @State private var date = Date()

    var body: some View {
        let task = taskStore.tasks[index]
        VStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        self.isShowingImagePicker = true
                    }
            } else {
                Image(uiImage: task.photo)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        self.isShowingImagePicker = true
                    }
            }

            DatePicker("Due Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())

            TextField("Notes", text: $notes)

            Button("Save Task") {
                if let uiImage = uiImage {
                    task.photo = uiImage
                }
                task.dueDate = date
                task.notes = notes
                taskStore.tasks[index] = task
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(uiImage == nil)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: self.$uiImage)
        }
        .onAppear {
            self.uiImage = task.photo
            self.date = task.dueDate
            self.notes = task.notes ?? ""
        }
    }
}
