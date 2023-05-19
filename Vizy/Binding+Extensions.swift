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
