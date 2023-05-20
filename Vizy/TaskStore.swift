//
//  TaskStore.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//
import Foundation
import UIKit

class TaskStore: ObservableObject {
    @Published var tasks = [Task]()

    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func updateTask(_ task: Task, at index: Int) {
        tasks[index] = task
    }
}
