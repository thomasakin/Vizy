//
//  NewTaskView.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData
import Speech


struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isCreatingNewTask: Bool
    @State var identifiableImage: IdentifiableImage?
    @State private var state: TaskState = .todo
    @State private var date = Date()
    @State private var isShowingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var notes = ""
    @State private var myname = ""
    @State private var isRecording = false
    @State private var speechText = ""
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    enum RecordingButton {
        case none
        case notes
        case title
        // Add more cases for additional buttons
    }

    @State private var recordingButton: RecordingButton = .none
    
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
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.yellow)
                }
            }
            .onTapGesture {
                isShowingImagePicker = true
            }
            
            HStack {
                Picker("State", selection: $state) {
                    ForEach(TaskState.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Button(action: {
                    isShowingImagePicker = true
                    imagePickerSourceType = .photoLibrary
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                }
                Button(action: {
                    isShowingImagePicker = true
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        imagePickerSourceType = .camera
                    } else {
                        imagePickerSourceType = .photoLibrary
                    }
                }) {
                    Image(systemName: "camera")
                }
            }
            
            VStack {
                DatePicker("Due Date", selection: $date, displayedComponents: .date)
                HStack {
                    HStack {
                        Text("Title")
                        transcribeButton(for: $myname, button: .title)
                    }.frame(minWidth: 90.0, maxHeight: 30.0, alignment: .topLeading)
                    TextEditor(text: $myname)
                        .border(Color.gray, width: 0.5)
                        .frame(minWidth: 90.0, maxHeight: 30.0, alignment: .topLeading)
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize - 4))
                }
                HStack {
                    HStack {
                        Text("Notes")
                        transcribeButton(for: $notes, button: .notes)
                    }.frame(minWidth: 90.0, maxHeight: 80.0, alignment: .topLeading)
                    TextEditor(text: $notes)
                        .border(Color.gray, width: 0.5)
                        .frame(minWidth: 90.0, maxHeight: 80.0, alignment: .topLeading)
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize - 4))
                }
                Spacer()
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
                    newTask.name = myname
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
                }, sourceType: imagePickerSourceType)
            }
        }
    }
        
    private func transcribeButton(for text: Binding<String>, button: RecordingButton) -> some View {
        Button(action: {
            if self.recordingButton == .none || self.recordingButton == button {
                self.isRecording.toggle()
                if self.isRecording {
                    self.startRecording()
                    self.recordingButton = button
                } else {
                    self.stopRecording(to: text)
                    self.recordingButton = .none
                }
            }
        }) {
            Image(systemName:
                self.recordingButton == .none || self.recordingButton == button ?
                (isRecording ? "stop.circle" : "mic") :
                "mic.slash"
            )
        }
    }

    private func startRecording() {
        // Start recording and transcribing speech
        self.speechRecognizer.resetTranscript()
        self.speechRecognizer.startTranscribing()
        self.isRecording = true
    }

    private func stopRecording(to text: Binding<String>) {
        // Stop recording and transcribing speech
        self.speechRecognizer.stopTranscribing()
        text.wrappedValue = self.speechRecognizer.transcript
        self.isRecording = false
    }
}
