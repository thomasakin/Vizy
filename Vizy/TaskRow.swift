//
//  TaskRow.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI

struct TaskRow: View {
    var task: Task

    var body: some View {
        HStack {
            Image(uiImage: task.photo)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text("\(task.dueDate, formatter: Self.dateFormatter)")
                Text(task.notes)
            }
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
