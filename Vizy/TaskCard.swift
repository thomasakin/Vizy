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
    @EnvironmentObject var settings: Settings
    @State var showDetails = false
    @GestureState var isLongPress = false

    @Environment(\.managedObjectContext) private var viewContext

    //@available(iOS 16.0, *)
    @available(iOS 16.0, *)
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
                        //Text(task.name ?? "")
                        //Text(task.name ?? "")
                        //    .foregroundColor(Color.black)
                        //    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize - 4))
                        //Spacer()
                        Text(TaskState(rawValue: task.stateRaw ?? "")?.rawValue ?? "")
                            .font(.system(size: getFontSize(for: task)))
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .bold()
                            .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                        Spacer()
                        Text(getFormattedDate(from: task.dueDate))
                            .font(.system(size: getFontSize(for: task)))
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .bold()
                            .foregroundColor(dueDateColor(for: task.dueDate ?? Date(), state: TaskState(rawValue: task.stateRaw ?? "") ?? .todo))
                            .strikethrough(task.stateRaw == TaskState.done.rawValue)
                    }
                    .background(
                        Capsule()
                            .foregroundColor(stateColor(state: TaskState(rawValue: task.stateRaw!) ?? .todo).opacity(0.90))
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
                    .lineLimit(3) // Limit to three lines
                    .truncationMode(.tail) // Add ellipsis if the text is truncated
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
        return (UIFont.preferredFont(forTextStyle: .body).pointSize - 1)
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
