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
            Spacer().frame(height: self.topSafeArea)
            
            Text("사용자가 복습하는 패턴을 분석해,\n중요한 내용을 오래 기억할 수 있도록 도와주는 일정 관리 앱입니다.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .font(.pretendard(size: 20))
                .lineSpacing(20 * 0.2)
                .padding(.vertical, 20)
            VStack(spacing: 10) {
                Image(systemName: "hourglass")
                    .font(.system(size: 38))
                    .foregroundColor(.black)
                Text("본인 나이대를 선택해주세요.")
                    .font(.pretendard(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black87)
            }
            let ages = [
                (text: "10대", value: 5),
                (text: "20대", value: 4),
                (text: "30대", value: 3),
                (text: "40대", value: 2),
                (text: "50대", value: 1)
            ]
            HStack {
                Spacer()
                ForEach(ages, id: \.value) { index in
                    Button(action: {
                        vm.selectAge(value: index.value)
                    }) {
                        VStack() {
                            Image(systemName: vm.isSelectAge(value: index.value) ? "circle.circle" : "circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(index.text)
                                .font(.pretendard(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color.black58)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            VStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 38))
                    .foregroundColor(.black)
                Text("본인이 생각하는 본인의 기억력을 선택해주세요.")
                    .font(.pretendard(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black87)
            }
            let recallLevel = [
                (text: "매우 좋음", value: 5),
                (text: "좋음", value: 4),
                (text: "보통", value: 3),
                (text: "약간 부족", value: 2),
                (text: "나쁨", value: 1)
            ]
            HStack {
                Spacer()
                ForEach(recallLevel, id: \.value) { index in
                    Button(action: {
                        vm.selectMemoryLevel(value: index.value)
                    }) {
                        VStack {
                            Image(systemName: vm.isSelectMemoryLevel(value: index.value) ? "circle.circle" : "circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(index.text)
                                .font(.pretendard(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color.black58)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            Spacer()
            if vm.isAccessToEvents && vm.isAccessToReminders {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 4)
                    .frame(height: 60)
                    .overlay {
                        Image(systemName: "checkmark.seal.fill")
                            .padding(.top, 4)
                            .font(.tenada(size: 24))
                            .foregroundStyle(.green)
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
            } else {
                Button {
                    self.vm.moveSetting()
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 4)
                        .frame(height: 60)
                        .overlay {
                            Text("캘린더 & 미리알림 권한주기")
                                .padding(.top, 4)
                                .font(.tenada(size: 24))
                                .foregroundStyle(.black)
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 24)
                }
            }
            
            Text("캘린더와 미리알림에 일정을 자동등록합니다. 이외에는 사용하지 않습니다.")
                .font(.pretendard(size: 12, weight: .semibold))
                .foregroundStyle(Color.black58)
                .padding(.bottom, 16)
            Button {
                self.isFirstLaunch = true
                Task { @MainActor in
                    vm.saveUserData()
                }
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 4)
                    .frame(height: 60)
                    .overlay {
                        Text("기억하러가기")
                            .padding(.top, 4)
                            .font(.tenada(size: 24))
                            .foregroundStyle(.black)
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
            }
        }
        .onAppear() {
            vm.requestPermissions()
        }
        .background(
            Color.white.opacity(vm.updateView ? 0.0000001 : 0.00000000001)
        )
        .ignoresSafeArea()
    }
}
#Preview {
    RememberThisSplashView()
}
