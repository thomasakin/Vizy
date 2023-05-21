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

    init(photo: UIImage, dueDate: Date, notes: String) {
        self.photo = IdentifiableImage(uiImage: photo)
        self.dueDate = dueDate
        self.notes = notes
    }
}
