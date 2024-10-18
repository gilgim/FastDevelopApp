//
//  AddView.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI

struct RememberThisAddView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectDateIndex: Int?
    @State var vm = RememberThisAddViewModel()
    var body: some View {
        @Bindable var bindingVm = vm
        VStack(alignment: .leading, spacing: 0) {
            //  기억 제목
            Group {
                Text("기억 제목")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex:"666666"))
                    .padding(.top, 16)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color(hex:"DDDDDD"))
                    TextField("기억할 이름을 입력하세요.", text: $bindingVm.rememberThisName)
                        .padding(.horizontal, 16)
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex:"333333"))
                }
                .frame(width: .deviceWidth - 32, height: 50)
                .padding(.top, 8)
            }
            .padding(.leading, 16)
            //  날짜 선택
            Group {
                Text("기억 설명")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex:"666666"))
                    .padding(.top, 16)
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color(hex:"DDDDDD"))
                    TextEditor(text: $bindingVm.rememberThisDescription)
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex:"333333"))
                        .padding(12)
                    if vm.rememberThisDescription.isEmpty {
                        Text("기억에 대한 설명을 입력하세요.")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundStyle(Color(hex:"CCCCCC"))
                            .padding(12)
                            .padding(.leading, 5)
                            .padding(.top, 8)
                    }
                }
                .frame(width: .deviceWidth - 32, height: 100)
                .padding(.top, 8)
            }
            .padding(.leading, 16)
            Group {
                Text("기억 주기")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex:"666666"))
                    .padding(.top, 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(1..<vm.rememberRepeatDates.count, id: \.self) { index in
                            let dateText = vm.rememberRepeatCycle( targetIndex: index)
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color(hex:"DDDDDD"))
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.white)
                                    .padding(2)
                                Text(dateText)
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundStyle(Color(hex:"333333"))
                                    .padding(.horizontal, 12)
                            }
                            .frame(height: 44)
                            .onTapGesture {
                                self.selectDateIndex = index
                            }
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color(hex:"007AFF"))
                            RoundedRectangle(cornerRadius: 7)
                                .padding(1)
                                .foregroundStyle(.white)
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(Color(hex:"007AFF"))
                                .fontWeight(.bold)
                        }
                        .frame(width: 80, height: 44)
                        .onTapGesture {
                            vm.addDate()
                        }
                        Spacer()
                    }
                }
                .frame(height: 60)
            }
            .padding(.leading, 16)
            Toggle("캘린더에 추가", isOn: $bindingVm.isAddAccessCalendar)
                .padding(.horizontal, 24)
            Toggle("미리알림에 추가", isOn: $bindingVm.isAddAccessReminder)
                .padding(.horizontal, 24)
            Spacer()
        }
        .toolbar {
            Button("Ok") {
                Task {
                    await self.vm.createRemember()
                    self.dismiss()
                }
            }
        }
        .sheet(isPresented: .constant(self.selectDateIndex != nil)) {
            self.selectDateIndex = nil
            self.vm.sortDate()
        } content: {
            if let index = selectDateIndex {
                DatePicker(
                    "날짜 선택",
                    selection: $bindingVm.rememberRepeatDates[index],
                    in: Date()...
                )
                .datePickerStyle(.graphical)
            }
        }

    }
}

#Preview {
    RememberThisAddView()
}
struct ForgettingCurveWithReviewView: View {
    // 초기 기억값과 망각 속도 상수
    let S: Double = 100
    let decayConstant: Double = 1.0
    
    // 복습 주기 리스트를 상태 변수로 정의
    @State private var reviewTimes: [Double] = [1, 3, 6] // 기본 복습 주기
    
    // 기억 보유량 계산 함수
    func retention(at time: Double) -> Double {
        // 마지막 복습 시점 찾아서 그 시점에서의 망각 곡선 계산
        var retentionValue: Double = S
        var lastReviewTime: Double = 0
        
        for reviewTime in reviewTimes {
            if time >= reviewTime {
                lastReviewTime = reviewTime
                retentionValue = S // 복습 시점마다 기억이 회복된다고 가정
            }
        }
        
        // 마지막 복습 이후 시간에 따른 망각 계산
        let timeSinceLastReview = time - lastReviewTime
        return retentionValue * exp(-timeSinceLastReview / decayConstant)
    }
    
    var body: some View {
        VStack {
            Text("에빙하우스 망각 곡선 (복습 포함)")
                .font(.headline)
                .padding()
            
            // 그래프 영역
            GeometryReader { geometry in
                ZStack {
                    // X축과 Y축 라벨
                    VStack {
                        Spacer()
                        HStack {
                            Text("기억 보유량 (%)")
                                .rotationEffect(.degrees(-90))
                                .offset(y: -50)
                            Spacer()
                        }
                        .padding(.leading, 10)
                    }
                    
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("시간 (t)")
                        }
                        .padding(.bottom, 10)
                    }
                    
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        // 시간을 0에서 10까지 진행하면서 각 시간에 대한 기억 보유량을 계산하고 라인을 그림
                        for time in stride(from: 0.0, to: 10.0, by: 0.1) {
                            let x = CGFloat(time / 10.0) * width
                            let y = CGFloat(1.0 - retention(at: time) / S) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
            .frame(height: 300)
            .padding()
            
            // 복습 주기 표시 및 설정
            Text("복습 시간: \(reviewTimes.map { String(format: "%.1f", $0) }.joined(separator: ", ")) 시간 후")
                .font(.subheadline)
                .padding()
            
            // 슬라이더를 통해 복습 주기 설정
            VStack {
                ForEach(0..<reviewTimes.count, id: \.self) { index in
                    HStack {
                        Text("복습 \(index + 1) 시간: \(String(format: "%.1f", reviewTimes[index]))시간")
                        Slider(value: Binding(
                            get: { self.reviewTimes[index] },
                            set: { newValue in
                                withAnimation(.easeInOut) {
                                    self.reviewTimes[index] = newValue
                                }
                            }
                        ), in: 0...10, step: 0.1)
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
}
