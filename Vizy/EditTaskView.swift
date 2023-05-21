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
    @ObservedObject var task: Task

    @State private var isShowingImagePicker = false
    @State private var identifiableImage: IdentifiableImage? // Changed this from UIImage to IdentifiableImage
    @State private var notes: String
    @State private var date: Date
    @State private var state: TaskState // Add state property

    init(task: Task) {
        self.task = task
        self._identifiableImage = State(initialValue: task.photo) // Changed this from uiImage to identifiableImage
        self._notes = State(initialValue: task.notes)
        self._date = State(initialValue: task.dueDate)
        self._state = State(initialValue: task.state)
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
            
            Picker("State", selection: $state) {
                ForEach(TaskState.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }

            DatePicker("Due Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())

            TextField("Notes", text: $notes)

            Button("Save Task") {
                task.state = state // Save the selected state
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
