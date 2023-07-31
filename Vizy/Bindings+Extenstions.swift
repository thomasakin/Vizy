//
//  Binding+Extensions.swift
//  Vizy
//
//  Created by Thomas Akin on 5/19/23.
//

import Foundation
import SwiftUI

extension Binding where Value: MutableCollection, Value.Index == Int {
    func element(_ idx: Int) -> Binding<Value.Element> {
        return Binding<Value.Element>(
            get: {
                return self.wrappedValue[idx]
            }, set: { (value: Value.Element) -> () in
                self.wrappedValue[idx] = value
            })
    }
}

// Default IdentifiableImage for Initialization
extension IdentifiableImage {
    static var defaultIdentifiableImage: IdentifiableImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(UIColor.systemYellow.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return IdentifiableImage(uiImage: image)
    }
}

// Default Image for Initialization
extension UIImage {
    static var defaultImage: UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(UIColor.systemYellow.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}

extension CoreDataTask {
    func toggleState() {
        guard let currentState = TaskState(rawValue: self.stateRaw ?? "") else {
            return
        }
        switch currentState {
        case .todo:
            self.stateRaw = TaskState.doing.rawValue
        case .doing:
            self.stateRaw = TaskState.done.rawValue
        case .done:
            self.stateRaw = TaskState.todo.rawValue
        }
    }
}

func dueDateColor(for date: Date, state: TaskState) -> Color {
    let today = Calendar.current.startOfDay(for: Date())
    let dueDate = Calendar.current.startOfDay(for: date)

    if dueDate < today && state != .done {
        return Color(red: 232/255, green: 65/255, blue: 24/255).opacity(0.75)
    } else if Calendar.current.isDateInToday(dueDate) {
        return Color(red: 156/255, green: 136/255, blue: 255/255).opacity(0.75)
    } else if dueDate > today {
        return Color(red: 245/255, green: 246/255, blue: 250/255).opacity(0.75)
    } else if state == .done {
        return Color(red: 220/255, green: 221/255, blue: 225/255).opacity(0.75)
    } else {
        return Color.primary.opacity(0.75)
    }
}

//extension Task {
//    var isOverdue: Bool {
//        return Date() > dueDate
//    }
//}
