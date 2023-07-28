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
    case todo = "Todo"
    case doing = "Doing"
    case done = "Done"
    
    var order: Int {
        switch self {
        case .todo: return 0
        case .doing: return 1
        case .done: return 2
        }
    }
    
    static func < (lhs: TaskState, rhs: TaskState) -> Bool {
        return lhs.order < rhs.order
    }
    
    mutating func toggle() {
        switch self {
        case .todo:
            self = .doing
        case .doing:
            self = .done
        case .done:
            self = .todo
        }
    }
}

extension TaskState {
    var color: Color {
        switch self {
        case .todo:
            return Color.paleGreenColor
        case .doing:
            return Color.softYellowColor
        case .done:
            return Color.doneTaskColor
        }
    }
}

extension Color {
    static let paleGreenColor = Color(UIColor(red: 0.30, green: 0.82, blue: 0.22, alpha: 1.00))
    static let softYellowColor = Color(UIColor(red: 0.98, green: 0.77, blue: 0.19, alpha: 1.00))
    static let doneTaskColor = Color(UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1.00)) // #dcdde1
}
