//
//  Task.swift
//  Vizy
//
//  Created by Thomas Akin on 5/18/23.
//

import Foundation
import SwiftUI
import UIKit
import CoreData

// Keep IdentifiableImage if it is used elsewhere in your app
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let uiImage: UIImage
}

enum TaskState: String, CaseIterable, Comparable {
    case new = "New"
    case doing = "Doing"
    case done = "Done"
    
    var order: Int {
        switch self {
        case .new: return 0
        case .doing: return 1
        case .done: return 2
        }
    }
    
    static func < (lhs: TaskState, rhs: TaskState) -> Bool {
        return lhs.order < rhs.order
    }
    
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

// Update Task class to inherit from NSManagedObject and rename to CoreDataTask
//public class CoreDataTask: NSManagedObject, Identifiable {
//    @NSManaged public var id: UUID
//    @NSManaged public var photoData: Data
//    @NSManaged public var dueDate: Date
//    @NSManaged public var notes: String
//    @NSManaged public var stateRaw: String
//
    // Convert Data to IdentifiableImage
//    var photo: IdentifiableImage {
//        get {
//            let image = UIImage(data: photoData) ?? UIImage()
//            return IdentifiableImage(uiImage: image)
//        }
//        set {
//            photoData = newValue.uiImage.pngData()!
//        }
//    }
    
    // Convert String to TaskState
//    var state: TaskState {
//        get {
//            return TaskState(rawValue: stateRaw) ?? .new
//        }
//        set {
//            stateRaw = newValue.rawValue
//        }
//    }
    
    // Toggle the task state
//    @objc func toggleState() {
//        state.toggle()
//    }
//}
