//
//  SettingsView.swift
//  Vizy
//
//  Created by Thomas Akin on 7/31/23.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @Published var dueDateDisplay: Int {
        didSet {
            NSUbiquitousKeyValueStore.default.set(Int64(dueDateDisplay), forKey: "dueDateDisplay")
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    init() {
        self.dueDateDisplay = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "dueDateDisplay"))
    }
}

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode
    let dueDateDisplayOptions = ["Show Due Dates", "Show Days Until Due"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Due")) {
                    Picker("Display", selection: $settings.dueDateDisplay) {
                        ForEach(0 ..< dueDateDisplayOptions.count, id: \.self) {
                            Text(self.dueDateDisplayOptions[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
        }
    }
}
