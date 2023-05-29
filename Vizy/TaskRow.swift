//
//  TaskRow.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct TaskRow: View {
    let task: CoreDataTask

    var body: some View {
        HStack {
            if let data = task.photoData, let uiImage = UIImage(data: data) {
                let identifiableImage = IdentifiableImage(uiImage: uiImage)
                Image(uiImage: identifiableImage.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(task.note ?? "")
                    .lineLimit(2)
                    .font(.headline)
                Text(task.dueDate ?? Date(), style: .date)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Text(task.stateRaw ?? "")
                .foregroundColor(task.stateColor)
                .font(.headline)
        }
    }
}

extension CoreDataTask {
    var stateColor: Color {
        guard let taskState = TaskState(rawValue: stateRaw ?? "") else { return .primary }
        return taskState.color
    }
}
