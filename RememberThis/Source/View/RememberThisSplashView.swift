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
        VStack {
            Spacer()
            Text("미리알림과 캘린더에 암기일정을 쉽게 추가할 수 있다.!!")
                .font(.headline)
            Spacer()
            Button("닫기") {
                self.isFirstLaunch = true
            }
        }
        .onAppear() {
            vm.requestPermissions()
        }
    }
}
