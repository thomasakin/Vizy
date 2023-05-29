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

        context.setFillColor(UIColor.gray.cgColor)
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

        context.setFillColor(UIColor.gray.cgColor)
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
        case .new:
            self.stateRaw = TaskState.doing.rawValue
        case .doing:
            self.stateRaw = TaskState.done.rawValue
        case .done:
            self.stateRaw = TaskState.new.rawValue
        }
    }
}

//extension Task {
//    var isOverdue: Bool {
//        return Date() > dueDate
//    }
//}
