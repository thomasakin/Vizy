//
//  NewTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isCreatingNewTask: Bool
    @State var identifiableImage: IdentifiableImage?
    @State private var state: TaskState = .new
    @State private var date = Date()
    @State private var isShowingImagePicker = false
    @State private var notes = ""
    
    init(image: IdentifiableImage?, isCreatingNewTask: Binding<Bool>) {
        self._isCreatingNewTask = isCreatingNewTask
        self._identifiableImage = State(initialValue: image ?? IdentifiableImage(uiImage: UIImage.defaultImage))
    }

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
            .pickerStyle(MenuPickerStyle())
            DatePicker("Due Date", selection: $date, displayedComponents: .date)
            TextEditor(text: $notes)
                .border(Color.gray, width: 0.5)
            Button("Save Task") {
                let newTask = CoreDataTask(context: viewContext)
                newTask.id = UUID()
                
                if let imageData = identifiableImage?.uiImage.jpegData(compressionQuality: 1.0) {
                    newTask.photoData = imageData
                } else if let defaultImageData = UIImage.defaultImage.jpegData(compressionQuality: 1.0) {
                    newTask.photoData = defaultImageData
                }
                
                newTask.dueDate = date
                newTask.note = notes
                newTask.stateRaw = state.rawValue
                
                do {
                    try viewContext.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(false)
        }
        .padding()
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: self.$identifiableImage, onImageSelected: { photoData in
                identifiableImage = IdentifiableImage(uiImage: UIImage(data: photoData) ?? UIImage.defaultImage)
            })
        }
    }
}
