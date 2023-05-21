//
//  Task.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI
import UIKit

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let uiImage: UIImage
}

// Update the TaskState enum
enum TaskState: String, CaseIterable {
    case new = "New"
    case doing = "Doing"
    case done = "Done"

    mutating func toggle() {
        switch self {
        case .new:
            self = .doing
        case .doing:
            self = .done
        case .done:
            self = .new
        }
    }
}

class Task: Identifiable, ObservableObject, Hashable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    @Published var photo: IdentifiableImage
    @Published var dueDate: Date
    @Published var notes: String
    @Published var state: TaskState

    init(photo: UIImage, dueDate: Date, notes: String, state: TaskState = .new) {
        self.photo = IdentifiableImage(uiImage: photo)
        self.dueDate = dueDate
        self.notes = notes
        self.state = state
    }
    
    // Toggle the task state
    func toggleState() {
        state.toggle()
    }
}
