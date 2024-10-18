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
    @State var isShowMask: Bool = true
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch == false {
                RememberThisSplashView()
            } else {
                ZStack {
                    RememberThisListView()
//                    if isShowMask {
//                        RememberThisMaskView()
//                            .onAppear() {
//                                Task {
//                                    try? await Task.sleep(nanoseconds: 600_000_000)
//                                    self.isShowMask = false
//                                }
//                            }
//                    }
                }
            }
        }
        .modelContainer(RememberThisSwiftDataConfiguration.container)
    }
}
