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
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch == false {
                RememberThisSplashView()
            } else {
                RememberThisListView()
            }
        }
        .modelContainer(RememberThisSwiftDataConfiguration.container)
    }
}
