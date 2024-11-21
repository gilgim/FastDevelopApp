//
//  ListView.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI
import SwiftData
import ACarousel

struct RememberThisListView: View {
    @State var vm = RememberThisListViewModel()
    @State var isShowMask: Bool = true
    @State var selected: RememberScheduleModel?
    @State var isDeletePresented: Bool = false
    @State var isRepeatTry: Bool = false
    @State var focusIndex: Int = 0
    var navigationPath: NavigationPath = .init()
    var body: some View {
        NavigationStack {
            ZStack {
                if !vm.rememberThisForViews.isEmpty {
                    ACarousel(vm.rememberThisForViews,
                              id: \.id,
                              index: $focusIndex,
                              spacing: 20,
                              headspace: 20,
                              isWrap: true,
                              autoScroll: .inactive) { content in
                        ZStack {
                            Color.white
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(content.name)
                                        .font(.pretendard(size: 20, weight: .semibold))
                                        .foregroundStyle(Color.black87)
                                        .lineLimit(3)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                }
                                .padding(.top, 20)
                                HStack(alignment: .top, spacing: 0) {
                                    Text("생성일 : ")
                                        .font(.tenada(size: 14))
                                        .foregroundStyle(Color.black87)
                                    Text(content.createdDateText)
                                        .font(.tenada(size: 14))
                                        .foregroundStyle(Color.black58)
                                }
                                .padding(.top, 18)
                                HStack(alignment: .top, spacing: 0) {
                                    Text("달성률 : ")
                                        .font(.tenada(size: 14))
                                        .foregroundStyle(Color.black87)
                                    Text(content.achievement)
                                        .font(.tenada(size: 14))
                                        .foregroundStyle(Color.black58)
                                }
                                .padding(.top, 8)
                                if let achievementListTexts = content.achievementListTexts {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("복습예정")
                                            .font(.tenada(size: 14))
                                            .foregroundStyle(Color.black87)
                                        ForEach(achievementListTexts, id: \.self) { text in
                                            HStack {
                                                Text(text)
                                                    .font(.tenada(size: 14))
                                                    .foregroundStyle(Color.black58)
                                                    .padding(.top, 6)
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                if let achievementPlanListTexts = content.achievementPlanListTexts {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("복습예정")
                                            .font(.tenada(size: 14))
                                            .foregroundStyle(Color.black87)
                                        ForEach(achievementPlanListTexts, id: \.self) { text in
                                            HStack {
                                                Text(text)
                                                    .font(.tenada(size: 14))
                                                    .foregroundStyle(Color.black58)
                                                    .padding(.top, 6)
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                }

                                if let todayRememberDate = content.todayRememberDate, !content.isFail {
                                    Text("이 챌린지는 오늘 복습예정이 있습니다.")
                                    Spacer()
                                    TimelineView(.animation) { context in
                                        Button {
                                            
                                        } label: {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(lineWidth: 4)
                                                .frame(height: 60)
                                                .overlay {
                                                    Text("복습완료")
                                                        .padding(.top, 4)
                                                        .font(.tenada(size: 24))
                                                        .foregroundStyle(
                                                            Color(
                                                                white: 0.2 + abs(sin(context.date.timeIntervalSinceReferenceDate * .pi / 1.8)) * 0.6
                                                            )
                                                        )
                                                }
                                                .padding(.bottom, 34)
                                                .foregroundStyle(
                                                    Color(
                                                        white: 0.2 + abs(sin(context.date.timeIntervalSinceReferenceDate * .pi / 1.8)) * 0.6
                                                    )
                                                )
                                        }
                                    }
                                } else {
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 2)
                            )
                            .frame(width: 300, height: 500)
                            if content.isFail {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(Color.black58)
                                    VStack {
                                        Text("실패 목록")
                                            .font(.tenada(size: 18))
                                            .foregroundStyle(.white)
                                            .padding(.top, 48)
                                        Spacer()
                                        HStack(spacing: 48) {
                                            Button {
                                                
                                            } label: {
                                                VStack {
                                                    Image(systemName: "arrow.counterclockwise")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 36, height: 36)
                                                    Text("다시하기")
                                                        .font(.tenada(size: 14))
                                                        .padding(.top, 2)
                                                }
                                                .foregroundStyle(Color.white)
                                            }
                                            Button {
                                                
                                            } label: {
                                                VStack {
                                                    Image(systemName: "xmark")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 28, height: 28)
                                                        .frame(width: 36, height: 36)
                                                    Text("포기하기")
                                                        .font(.tenada(size: 14))
                                                        .padding(.top, 2)
                                                }
                                                .foregroundStyle(Color.white)
                                            }
                                        }
                                        .padding(.bottom, 34)
                                    }
                                }
                                .frame(width: 300, height: 500)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 2)
                                        .foregroundStyle(Color.customSilver)
                                )
                            }
                        }
                        .frame(width: 300, height: 500)
                    } bottomFirstClick: { content, index in
                        self.vm.selectRememberThis(content)
                        self.focusIndex = index > 0 ? index-1 : 0
                        isDeletePresented.toggle()
                    } bottomSecondClick: { rememberThis, index in
                        
                    }
                } else {
                    Text("+버튼을 눌러 복습 챌린지를 생성해주세요.")
                        .multilineTextAlignment(.center)
                        .lineSpacing(24 * 0.12)
                        .font(.tenada(size: 24))
                }
            }
            .alert("삭제", isPresented: $isDeletePresented, actions: {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    vm.deleteRemember()
                }
            })
            .alert("다시하기", isPresented: $isRepeatTry, actions: {
                Button("취소", role: .cancel) {}
                Button("다시하기", role: .destructive) {
                    
                }
            }, message: {Text("챌린지를 다시하시겠습니까? 현재날짜로 갱신되어 동일 복습주기를 가지게 됩니다.")})
            .toolbar {
                NavigationLink {
                    RememberThisAddView()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .onAppear() {
                vm.loadRememberSchedules()
            }
        }
    }
}

#Preview {
    RememberThisListView()
}
