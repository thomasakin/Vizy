//
//  GroupedTasksRow.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI
import CoreData

struct GroupedTasksRow: View {
    let tasks: [CoreDataTask]

    var body: some View {
        HStack {
            ForEach(tasks, id: \.id) { task in
                TaskCard(task: task)
            }
            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}
