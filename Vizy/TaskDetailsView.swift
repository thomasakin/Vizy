//
//  TaskDetailsView.swift
//  Vizy
//
//  Created by Thomas Akin on 8/5/23.
//

import Foundation
import SwiftUI

struct TaskDetailsView: View {
    @ObservedObject var task: CoreDataTask
    @ObservedObject var taskStore: TaskStore
    @EnvironmentObject var settings: Settings
    @State var showDetails = false
    @GestureState var isLongPress = false
    
    @State private var isShowingImagePicker = false
    @State private var selectedImage: IdentifiableImage?
    @State private var isShowingDatePicker = false
    @State private var selectedDate: Date = Date()
    @State private var isEditingNote = false // State to control the note editing pop-up
    @State private var editedNote: String = "" // State to hold the edited note


    @Environment(\.presentationMode) var presentationModeBinding: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isShowingImageFullScreen = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack() {
                    Text(TaskState(rawValue: task.stateRaw ?? "")?.rawValue ?? "")
                        .font(.system(size: getFontSize(for: task)))
                        .bold()
                        .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                        .padding(.leading)
                    Spacer()
                    Text(task.dueDate ?? Date(), style: .date)
                        .strikethrough(TaskState(rawValue: task.stateRaw ?? "") == .done)
                        .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                        .onTapGesture {
                            selectedDate = task.dueDate ?? Date()
                            isShowingDatePicker = true
                        }
                        .popover(isPresented: $isShowingDatePicker) {
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .onChange(of: selectedDate) { newValue in
                                    task.dueDate = newValue
                                    saveContext()
                                    isShowingDatePicker = false
                                }
                            Button("Save") {
                                task.dueDate = selectedDate
                                saveContext()
                                isShowingDatePicker = false
                            }
                        }
                        .padding(.trailing)
                }
                .frame(height: getFontSize(for: task) + 8)
                .background(
                    Capsule()
                        .foregroundColor(stateColor(state: TaskState(rawValue: task.stateRaw!) ?? .todo))
                        .cornerRadius(8)
                        //.padding(.horizontal, -10.0)
                        .scaleEffect(isLongPress ? 1.05 : 1.0)
                        .animation(.easeInOut, value: isLongPress)
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .updating($isLongPress) { currentState, gestureState, transaction in
                                    gestureState = currentState
                                }
                                .onEnded { _ in
                                    taskStore.toggleState(forTask: task)
                                    saveContext()
                                }
                        )
                )
                .padding(4)
            }
            .padding(.top)
            // Default image if photoData can't be converted to UIImage
            //let uiImage = task.photoData.flatMap(UIImage.init(data:)) ?? UIImage(systemName: "photo")!
            if let data = task.photoData, let uiImage = UIImage(data: data) {
                let identifiableImage = IdentifiableImage(uiImage: uiImage)
                Image(uiImage: identifiableImage.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        isShowingImagePicker = true
                    }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        isShowingImagePicker = true
                    }
            }
            //if let data = task.photoData, let uiImage = UIImage(data: data) {
            //    let identifiableImage = IdentifiableImage(uiImage: uiImage)
            //    Image(uiImage: identifiableImage.uiImage)
            //        .resizable()
            //        .aspectRatio(contentMode: .fit)
            //        .onTapGesture {
            //            isShowingImageFullScreen = true
            //        }
            //        .fullScreenCover(isPresented: $isShowingImageFullScreen) {
            //            Image(uiImage: identifiableImage.uiImage)
            //                .resizable()
            //                .aspectRatio(contentMode: .fit)
            //                .edgesIgnoringSafeArea(.all)
            //                .onTapGesture {
            //                    isShowingImageFullScreen = false
            //                }
            //        }
            //} else {
            //    Image(systemName: "photo")
            //        .resizable()
            //        .aspectRatio(contentMode: .fit)
            //        .frame(maxWidth: .infinity)
            //}
            VStack(alignment: .leading) {
                Text(task.note ?? "")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize + 2))
                    .foregroundColor(Color.gray)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal, -10.0)
                    )
                    .onTapGesture {
                        editedNote = task.note ?? "" // Initialize the edited note with the current note
                        isEditingNote = true // Show the note editing pop-up
                    }
            }
            .padding(8) // Add horizontal padding
            Button(action: {
                viewContext.delete(task)
                saveContext()
                presentationModeBinding.wrappedValue.dismiss()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .onTapGesture {
            self.showDetails = true
        }
        .navigationBarItems(trailing: Button(action: {
            presentationModeBinding.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
        })
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, onImageSelected: { imageData in
                task.photoData = imageData
                saveContext()
            }, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $isEditingNote) {
            // Note editing pop-up
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isEditingNote = false // Dismiss the pop-up
                    }) {
                        Image(systemName: "xmark")
                            .padding()
                    }
                }
                TextEditor(text: $editedNote) // Text editor for the note
                    .padding()
                Button("Save") {
                    task.note = editedNote // Save the edited note
                    saveContext()
                    isEditingNote = false // Dismiss the pop-up
                }
                .padding()
            }
            .padding()
        }
    }
    
    func getFormattedDate(from date: Date?) -> String {
        if settings.dueDateDisplay == 1, let dueDate = date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
            return "\(components.day ?? 0)"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale.current

            let currentYear = Calendar.current.component(.year, from: Date())
            let targetYear = Calendar.current.component(.year, from: date ?? Date())

            if currentYear == targetYear {
                formatter.dateFormat = "MM/dd"
            } else {
                formatter.dateFormat = "MM/dd/yy"
            }

            return date.map(formatter.string) ?? ""
        }
    }
    
    private func getFontSize(for task: CoreDataTask) -> CGFloat {
        //return task.stateRaw == TaskState.done.rawValue ? 16 : 16 // Adjust sizes as needed
        return (UIFont.preferredFont(forTextStyle: .body).pointSize + 8)
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
