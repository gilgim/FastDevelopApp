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
            Text("캘린더와 미리알림에 기억하고 싶은 항목을 추가할 수 있습니다.")
            Text("반복학습을 통한 기억을 보존하기 위한 앱입니다.")
            Button {
                self.isFirstLaunch = true
            } label: {
                Text("기억하러가기")
            }
        }
        .onAppear() {
            vm.requestPermissions()
        }
        .ignoresSafeArea()
    }
}
