//
//  VizyApp.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import SwiftUI

@main
struct ToDoApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(TaskStore())
        }
    }
}
