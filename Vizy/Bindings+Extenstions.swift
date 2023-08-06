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
    //func toggleState() {
    //    guard let currentState = TaskState(rawValue: self.stateRaw ?? "") else {
    //        return
    //    }
    //    switch currentState {
    //    case .todo:
    //        self.stateRaw = TaskState.doing.rawValue
    //    case .doing:
    //        self.stateRaw = TaskState.done.rawValue
    //    case .done:
    //    self.stateRaw = TaskState.todo.rawValue
    //    }
    // }
}

extension Color {
    static let todoColor = Color(hex: "#FEC601")
    static let doingColor = Color(hex: "#3DA5D9")
    static let doneColor = Color(hex: "#73BFB8")
    static let pastDueFontColor = Color(hex: "#af0808")
    static let todoDueTodayFontColor = Color(hex: "#EA7317")
    static let doingDueTodayFontColor = Color(hex: "#A85413")
    static let todoFutureDueFontColor = Color(hex: "#F4F4EC")
    static let doingFutureDueFontColor = Color(hex: "#E5E4E2")
    static let doneFontColor = Color(hex: "#4F5933")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func stateColor(state: TaskState) -> Color {
    if state == TaskState.done {
        return Color.doneColor
    } else if state == TaskState.todo {
        return Color.todoColor
    } else if state == TaskState.doing {
        return Color.doingColor
    } else {
        return Color.primary
    }
}

func dueDateColor(for date: Date, state: TaskState) -> Color {
    let today = Calendar.current.startOfDay(for: Date())
    let dueDate = Calendar.current.startOfDay(for: date)

    if state == .done {
        return Color.doneFontColor
    } else if dueDate < today {
        return Color.pastDueFontColor
    } else if state == .todo && Calendar.current.isDateInToday(dueDate) {
        return Color.todoDueTodayFontColor
    } else if state == .doing && Calendar.current.isDateInToday(dueDate) {
        return Color.doingDueTodayFontColor
    } else if state == .todo && dueDate > today {
        return Color.todoFutureDueFontColor
    } else if state == .doing && dueDate > today {
        return Color.doingFutureDueFontColor
    } else {
        return Color.primary
    }
}

