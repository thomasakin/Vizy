//
//  NewTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI

struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore
    @State private var identifiableImage: IdentifiableImage? = IdentifiableImage(uiImage: UIImage.defaultImage)
    @State private var state: TaskState = .new // Add state property
    
    
    @State private var date = Date()
    @State private var isShowingImagePicker = false
    @State private var uiImage: UIImage? = nil
    @State private var notes = ""

    var body: some View {
        VStack {
            VStack {
                if let identifiableImage = identifiableImage {
                    Image(uiImage: identifiableImage.uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                isShowingImagePicker = true
            }
            Picker("State", selection: $state) {
                ForEach(TaskState.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            DatePicker("Due Date", selection: $date, displayedComponents: .date)
            TextEditor(text: $notes)
                .border(Color.gray, width: 0.5)
            Button("Save Task") {
                let uiImage = identifiableImage?.uiImage ?? UIImage.defaultImage
                let task = Task(photo: uiImage, dueDate: date, notes: notes, state: state)
                taskStore.addTask(task)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(false)
        }
        .padding()
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: self.$identifiableImage)
        }
    }
}
