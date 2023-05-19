//
//  Task.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI
import UIKit

class Task: Identifiable, ObservableObject {
    let id = UUID()
    @Published var photo: UIImage
    @Published var dueDate: Date
    @Published var notes: String

    init(photo: UIImage, dueDate: Date, notes: String) {
        self.photo = photo
        self.dueDate = dueDate
        self.notes = notes
    }
}
