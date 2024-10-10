//
//  RememberThisApp.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI
import SwiftData

@main
struct RememberThisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [RememberModel.self, RemeberDateModel.self])
    }
}
