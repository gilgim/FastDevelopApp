//
//  AddView.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI

struct RememberThisAddView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectDateIndex: Int?
    @State private var lineMaxCount = 2
    @State private var scrollOffset: CGFloat = 0
    @State private var isAtEnd = false
    
    @State var vm = RememberThisAddViewModel()
    var body: some View {
        @Bindable var bindingVm = vm
        ScrollView {
            rememberIntervalGraph
            rememberIntervalVerticalLine
            rememberName
            rememberExplain
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
    var rememberIntervalGraph: some View {
        VStack {
            HStack {
                Text("기억 주기")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex:"666666"))
                Spacer()
                Text("캘린더에 추가")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: self.vm.isAddAccessCalendar ? "28A745" : "999999"))
                    .onTapGesture {
                        withAnimation {
                            self.vm.isAddAccessCalendar.toggle()
                        }
                    }
                Text("미리알림에 추가")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: self.vm.isAddAccessReminder ? "28A745" : "999999"))
                    .onTapGesture {
                        withAnimation {
                            self.vm.isAddAccessReminder.toggle()
                        }
                    }
                    .padding(.trailing, 16)
            }
            .padding(.top, 16)
        }
        .padding(.leading, 16)
    }
    var rememberIntervalVerticalLine: some View {
        GeometryReader { outerGeometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(0..<lineMaxCount, id: \.self) { i in
                            ZStack(alignment: .top) {
                                Rectangle()
                                    .foregroundStyle(.white)
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .frame(width: UIScreen.main.bounds.width, height: 1)
                                    .padding(.top, 3.5)
                            }
                            .onTapGesture {
                                self.vm.addDate()
                            }
                        }
                    }
                    HStack {
                        ForEach(vm.rememberRepeatDates, id: \.self) { date in
                            VStack(spacing: 8) {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.gray)
                                Text(date.formmatToString("yyyy년 MM월 dd일"))
                                    .foregroundColor(.gray)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        Spacer()
                    }
                }
                .background(
                    GeometryReader { innerGeometry in
                        Color.clear
                            .onChange(of: innerGeometry.frame(in: .global).minX) { _,  newValue in
                                let offset = newValue - outerGeometry.frame(in: .global).minX
                                scrollOffset = -offset
                                
                                let maxOffset = innerGeometry.size.width - outerGeometry.size.width
                                
                                if scrollOffset >= maxOffset {
                                    if !isAtEnd {
                                        isAtEnd = true
                                        lineMaxCount += 1
                                    }
                                } else {
                                    isAtEnd = false
                                }
                            }
                    }
                )
                .padding(.leading, 16)
            }
        }
        .frame(height: 20)
    }
    var rememberName: some View {
        @Bindable var bindingVm = vm
        return VStack(alignment: .leading, spacing: 0) {
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
    }
    var rememberExplain: some View {
        @Bindable var bindingVm = vm
        return VStack(alignment: .leading, spacing: 0) {
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
    }
}

#Preview {
    RememberThisAddView()
//    ForgettingCurveView()
//    CustomGraphView()
}
struct RememberRepeatSettingView: View {
    var body: some View {
        VStack {
            Text("1일")
            HStack {
                Text("암기 예정일 : 2024.10.11")
                
            }
        }
    }
}
import SwiftUI

struct ForgettingCurveView: View {
    let k: Double = 0.3 // 망각 계수
    let studyTimes: [Double] = [0, 5, 10, 15] // 첫 학습 및 복습 시점 (단위: 시간)
    let totalTime: Double = 20 // 총 경과 시간
    let maxRetention: Double = 1.5 // 화면에 맞추기 위한 최대 기억 유지율 (누적 값을 고려)
    
    // 개별 기억 유지율을 계산하는 함수
    func memoryRetention(at time: Double, studyTime: Double) -> Double {
        return exp(-k * (time - studyTime))
    }
    
    // 누적 기억 유지율을 계산하는 함수
    func totalRetention(at time: Double) -> Double {
        studyTimes.reduce(0) { total, studyTime in
            total + memoryRetention(at: time, studyTime: studyTime)
        }
    }
    
    var body: some View {
        VStack {
            Text("누적 기억 유지율 그래프")
                .font(.headline)
                .padding()

            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    for t in stride(from: 0, through: totalTime, by: 0.1) {
                        let x = CGFloat(t / totalTime) * width
                        let y = CGFloat(1.0 - min(totalRetention(at: t), maxRetention) / maxRetention) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // 복습 시점을 표시하는 축 라인
                ForEach(studyTimes, id: \.self) { studyTime in
                    let x = CGFloat(studyTime / totalTime) * geometry.size.width
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    .stroke(Color.red.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
            .frame(height: 300)
            .padding()
            
            // 복습 시점을 표시
            VStack {
                Text("복습 시점: \(studyTimes.map { String(format: "%.1f", $0) }.joined(separator: ", ")) 시간")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}

struct GraphView: View {
    // 수식에 따라 y 값을 계산하는 함수
    func calculateY(x: Double) -> Double {
        return x * x // 예제: y = x^2
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / 365 // 그래프의 x 값 증가 간격

                path.move(to: CGPoint(x: 0, y: height))

                for i in stride(from: 0, to: 365, by: 1) {
                    let x = Double(i) * step
                    let y = calculateY(x: x / width) * height
                    path.addLine(to: CGPoint(x: x, y: height - y))
                }
            }
            .stroke(Color.blue, lineWidth: 2) // 그래프 선 색상 및 두께 설정
        }
        .padding()
    }
}
import Foundation

struct CustomGraphView: View {
    func calculate(t: Double, r0: Double, n: Double, alpha0: Double, gamma: Double, beta: Double) -> Double {
        return exp(-(alpha0 * gamma/pow(n, beta))*t)
    }
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / 100000 // 그래프의 x 값 증가 간격

                path.move(to: CGPoint(x: 0, y: height))

                for i in stride(from: 0, to: 100000, by: 1) {
                    let x = Double(i) * step
                    let y = calculate(t: x / width, r0: 1, n: 1, alpha0: 0.3, gamma: 1.0, beta: 0.9) * height
                    path.addLine(to: CGPoint(x: x, y: height - y))
                }
            }
            .stroke(Color.blue, lineWidth: 2) // 그래프 선 색상 및 두께 설정
        }
    }
}
