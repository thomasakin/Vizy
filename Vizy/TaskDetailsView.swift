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

    @Environment(\.presentationMode) var presentationModeBinding: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isShowingImageFullScreen = false

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Text(TaskState(rawValue: task.stateRaw ?? "")?.rawValue ?? "")
                        .font(.system(size: getFontSize(for: task)))
                        .bold()
                        .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                    Spacer()
                    Text(getFormattedDate(from: task.dueDate))
                        .font(.system(size: getFontSize(for: task)))
                        .bold()
                        .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                        .strikethrough(task.stateRaw == TaskState.done.rawValue)
                }
                .background(
                    Capsule()
                        .foregroundColor(stateColor(state: TaskState(rawValue: task.stateRaw!) ?? .todo))
                        .cornerRadius(8)
                        .padding(.horizontal, -10.0)
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
            }
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
            }
            .padding(.all, 10)
        }
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .onTapGesture {
            self.showDetails = true
        }
        .padding()
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
