//
//  RememberThisSplashView.swift
//  RememberThis
//
//  Created by gaea on 10/11/24.
//

import SwiftUI
import EventKit

struct RememberThisSplashView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    let vm = RememberThisSplashViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                Text("캘린더에")
            }
            .onAppear() {
                vm.requestPermissions()
            }
            .toolbar {
                Button {
                    self.isFirstLaunch = true
                } label: {
                    Image(systemName: "xmark")
                        .tint(.white)
                }
            }
        }
    }
}
