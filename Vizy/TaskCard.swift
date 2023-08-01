//
//  TaskCard.swift
//  Vizy
//
//  Created by Thomas Akin on 5/29/23.
//

import SwiftUI

struct TaskCard: View {
    @ObservedObject var task: CoreDataTask
    @ObservedObject var taskStore: TaskStore
    @State var showDetails = false
    @GestureState var isLongPress = false

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            // Default image if photoData can't be converted to UIImage
            let uiImage = task.photoData.flatMap(UIImage.init(data:)) ?? UIImage(systemName: "photo")!
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width / 3 - 15, height: UIScreen.main.bounds.width / 3 - 15)
                .clipped()
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Text(task.name ?? "")
                            .foregroundColor(Color.black)
                            .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize - 4))
                        Spacer()
                        Text(getFormattedDate(from: task.dueDate))
                            .strikethrough(TaskState(rawValue: task.stateRaw ?? "") == .done)
                            .foregroundColor(Color.black)
                            .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize - 4))
                    }
                    .background(
                        Capsule()
                            .foregroundColor(TaskState(rawValue: task.stateRaw ?? "")?.color.opacity(0.80) ?? .primary.opacity(0.80))
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
                Spacer()
                Text(task.note ?? "")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize - 2))
                    .foregroundColor(Color.white)
                    .background(
                        Capsule()
                            .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(8)
                            .padding(.horizontal, -10.0)
                    )
            }
            .padding(.all, 10)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .cornerRadius(5)
        .shadow(radius: 5)
        .onTapGesture {
            self.showDetails = true
        }
        .padding(.all, 10)
        .sheet(isPresented: $showDetails) {
            NavigationView {
                TaskDetailsView(task: task, taskStore: taskStore)
            }
        }
    }

    func getFormattedDate(from date: Date?) -> String {
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

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
