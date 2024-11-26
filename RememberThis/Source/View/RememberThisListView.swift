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
    @State var isGiveUp: Bool = false
    @State var isReviewComplete: Bool = false
    @State var focusIndex: Int = 0
    @State var isShowMachineLearningExplain: Bool = false
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
                            Color.white.cornerRadius(12)
                            VStack(spacing: 0) {
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
                                    Spacer()
                                }
                                .padding(.top, 18)
                                HStack(alignment: .top, spacing: 0) {
                                    Text("달성률 : ")
                                        .font(.tenada(size: 14))
                                        .foregroundStyle(Color.black87)
                                    Text(content.achievement)
                                        .font(.tenada(size: 14))
                                        .foregroundStyle(Color.black58)
                                    Spacer()
                                }
                                .padding(.top, 8)
                                if let achievementListTexts = content.achievementListTexts {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("복습완료")
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
                                        Spacer()
                                    }
                                    .padding(.top, 8)
                                }
                                if let achievementPlanListTexts = content.achievementPlanListTexts {
                                    HStack {
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
                                        Spacer()
                                    }
                                    .padding(.top, 8)
                                }

                                if content.todayRememberDateText != nil, !content.isFail {
                                    TimelineView(.animation) { context in
                                        Text("이 챌린지는 당일 복습예정이 있습니다.")
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(24 * 0.15)
                                            .font(.tenada(size: 24))
                                            .foregroundStyle(Color.black)
                                            .padding(.top, 58)
                                    }
                                    Spacer()
                                    TimelineView(.animation) { context in
                                        Button {
                                            withAnimation {
                                                self.isReviewComplete.toggle()
                                                self.vm.selectRememberThis(content)
                                                self.vm.reviewComplete()
                                            }
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
                            if let failList = content.failList, content.isFail {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(Color.black58)
                                    VStack(spacing: 0) {
                                        Text("실패 목록")
                                            .font(.tenada(size: 18))
                                            .foregroundStyle(.white)
                                            .padding(.top, 48)
                                        ForEach(failList, id: \.self) { failDateText in
                                            Text(failDateText)
                                                .font(.tenada(size: 16))
                                                .foregroundStyle(.white)
                                            .padding(.top, 16)
                                        }
                                        Spacer()
                                        HStack(spacing: 48) {
                                            Button {
                                                vm.selectRememberThis(content)
                                                isRepeatTry.toggle()
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
                                                vm.selectRememberThis(content)
                                                isGiveUp.toggle()
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
                } else if vm.rememberThisForViews.isEmpty {
                    Text("+버튼을 눌러 복습 챌린지를 생성해주세요.")
                        .multilineTextAlignment(.center)
                        .lineSpacing(24 * 0.12)
                        .font(.tenada(size: 24))
                        .padding(.horizontal, 24)
                } else {
                    EmptyView()
                }
                if isReviewComplete {
                    reviewView
                }
            }
            .alert("삭제", isPresented: $isDeletePresented, actions: {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    vm.deleteRemember()
                }
            },message: {Text("챌린지를 삭제하시겠습니까?")})
            .alert("다시하기", isPresented: $isRepeatTry, actions: {
                Button("취소") {}
                Button("다시하기") {
                    Task { @MainActor in
                        await vm.rememberTry()
                    }
                }
            }, message: {Text("챌린지를 다시하시겠습니까? 현재날짜로 갱신되어 동일 복습주기를 가지게 됩니다.")})
            .alert("포기하기", isPresented: $isGiveUp, actions: {
                Button("취소") {}
                Button("포기하기") {
                    vm.rememberGiveUp()
                }.tint(.red)
            }, message: {Text("챌린지를 포기하시겠습니까? 포기한 챌린지는 삭제됩니다.")})
            .alert("알림", isPresented: $isShowMachineLearningExplain, actions: {
                Button("작성하기") {}
                Button("닫기") {
                    self.vm.reviewCompleteCancel()
                    self.vm.reviewReviewComplete()
                    self.isReviewComplete = false
                }
            }, message: {Text("개인 망각곡선을 학습하기 위해 사용됩니다. 서버에 저장되지 않습니다.")})
            .toolbar {
                NavigationLink {
                    RememberThisAddView()
                } label: {
                    Image(systemName: "plus")
                }.tint(isReviewComplete ? Color.black58 : .black)
            }
            .onAppear() {
                vm.loadRememberSchedules()
            }
        }
    }
    
    var reviewView: some View {
        ZStack {
            Color.black58
                .ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("개인화 학습리뷰")
                        .font(.pretendard(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black87)
                        .offset(x: 7.5)
                    Spacer()
                    Button {
                        self.isShowMachineLearningExplain.toggle()
                    }label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                    }
                }
                VStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 38))
                        .foregroundColor(.black)
                    Text("이전 암기 내용이 기억나시나요?")
                        .font(.pretendard(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black87)
                }
                let recallLevel = [
                    (text: "완벽", value: 5),
                    (text: "대부분", value: 4),
                    (text: "보통", value: 3),
                    (text: "거의 잊음", value: 2),
                    (text: "잊음", value: 1)
                ]
                HStack {
                    Spacer()
                    ForEach(recallLevel, id: \.value) { index in
                        Button(action: {
                            vm.selectRecallLevel(value: index.value)
                        }) {
                            VStack {
                                Image(systemName: self.vm.isSelectRecallLevel(value: index.value) ? "circle.circle" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text(index.text)
                                    .font(.pretendard(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(Color.black58)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                Divider()
                VStack(spacing: 10) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.black)
                    Text("이번 복습에 만족하셨나요?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                let satisfactionLevels = [
                    (text: "완벽", value: 5),
                    (text: "만족", value: 4),
                    (text: "보통", value: 3),
                    (text: "부족", value: 2),
                    (text: "매우 부족", value: 1)
                ]
                HStack {
                    Spacer()
                    ForEach(satisfactionLevels, id: \.value) { index in
                        Button(action: {
                            vm.selectReviewSatisfaction(value: index.value)
                        }) {
                            VStack {
                                Image(systemName: self.vm.isSelectReviewSatisfaction(value: index.value) ? "circle.circle" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text(index.text)
                                    .font(.pretendard(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(Color.black58)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                Button {
                    self.vm.reviewReviewComplete()
                    self.isReviewComplete.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 4)
                        .frame(height: 60)
                        .overlay {
                            Text("완료")
                                .padding(.top, 4)
                                .font(.tenada(size: 24))
                                .foregroundStyle(.black)
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    RememberThisListView()
}
