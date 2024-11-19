//
//  AddView.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI
import Combine


struct RememberThisAddView: View {
    @Environment(\.dismiss) var dismiss
    @State private var positionStream: PassthroughSubject<(index: Int, position: CGPoint), Never> = .init()
    @State private var selectedDateIndex: Int?
    @State private var maxLineCount = 100
    @State private var contentScrollOffset: CGFloat = 0
    @State private var isScrollingAtEnd = false
    
    @State private var viewModel = RememberThisAddViewModel()
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var isDatePickerVisible = false
    @State private var tapPosition: CGPoint = .zero
    @State private var currentIndex: Int = 0
    @State private var previousIndex: Int = 0
    @State private var nextIndex: Int = 0
    @State private var isNameVisible: Bool = true
    
    var body: some View {
        @Bindable var bindingViewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                rememberGraph
                rememberIntervalGraph
                rememberIntervalVerticalLine
                rememberNameField
                rememberDescriptionField
                Spacer()
                    .frame(height: 100)
            }
            .onTapGesture {
                self.hideKeyboard()
            }
        }
        .overlay {
            if isDatePickerVisible {
                GeometryReader { geometry in
                    Color.white.opacity(0.0000001)
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.15)) {
                                isDatePickerVisible = false
                            }
                        }
                    ZStack(alignment: .bottomTrailing) {
                        Rectangle()
                            .foregroundStyle(.white)
                        if let range = viewModel.dateRange(for: viewModel.rememberRepeatDates[currentIndex]) as? ClosedRange<Date> {
                            DatePicker("", selection: $bindingViewModel.rememberRepeatDates[currentIndex], in: range, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .scaleEffect(0.7)
                        } else if let range = viewModel.dateRange(for: viewModel.rememberRepeatDates[currentIndex]) as? PartialRangeFrom<Date> {
                            DatePicker("", selection: $bindingViewModel.rememberRepeatDates[currentIndex], in: range, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .scaleEffect(0.7)
                        } else if let range = viewModel.dateRange(for: viewModel.rememberRepeatDates[currentIndex]) as? PartialRangeThrough<Date> {
                            DatePicker("", selection: $bindingViewModel.rememberRepeatDates[currentIndex], in: range, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .scaleEffect(0.7)
                        }
                    }
                    .frame(width: 230, height: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 4, y: 4)
                    .offset(x: tapPosition.x, y: tapPosition.y - self.topSafeArea - self.navigationBarHeight + 20)
                }
            }
        }
        .onAppear() {
            subscriptions = []
            positionStream.sink { value in
                if value.position.x < 0 {
                    self.tapPosition = .init(x: 16, y: value.position.y + 36)
                } else if value.position.x + 250 > CGFloat.deviceWidth {
                    self.tapPosition = .init(x: CGFloat.deviceWidth - 250 - 16, y: value.position.y + 36)
                } else {
                    self.tapPosition = .init(x: value.position.x, y: value.position.y + 36)
                }
                self.currentIndex = value.index
                if currentIndex > 0 {
                    self.previousIndex = currentIndex - 1
                }
                if currentIndex != viewModel.rememberRepeatDates.count - 1 {
                    self.nextIndex = currentIndex + 1
                }
                withAnimation(.linear(duration: 0.15)) {
                    isDatePickerVisible = true
                }
            }.store(in: &subscriptions)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await self.viewModel.createRemember()
                        self.dismiss()
                    }
                }) {
                    Text("생성")
                        .font(.pretendard(size: 18, weight: .semibold))
                }
            }
        }
    }
    var rememberGraph: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("기억 곡선")
                .font(.headline)
                .padding(.leading, 16)

            GeometryReader { geometry in
                ZStack {
                    // 축 추가
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height

                        // x축
                        path.move(to: CGPoint(x: 0, y: height))
                        path.addLine(to: CGPoint(x: width, y: height))

                        // y축
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: height))
                    }
                    .stroke(Color.gray, lineWidth: 1)

                    // 점선 (예: x축 기준으로 일정 간격으로 추가)
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height

                        // y축 기준 점선 추가 (예: 25%, 50%, 75%)
                        for i in 1...3 {
                            let y = height * CGFloat(i) / 4
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                    }
                    .stroke(
                        Color.gray.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1, dash: [5, 5]) // 점선 스타일
                    )

                    // 그래프 그리기
                    Path { path in
                        let lastIndex = viewModel.dateIntervalsLastTarget() + 3
                        let xScale: CGFloat = geometry.size.width / CGFloat(lastIndex)
                        let height: CGFloat = geometry.size.height
                        path.move(to: CGPoint(x: 0, y: height))

                        // `intervals` 배열 가져오기
                        let intervals = viewModel.dateIntervals()

                        // 누적된 x 좌표 시작점
                        var startX: CGFloat = 0.0

                        // 첫 번째 구간
                        if let firstInterval = intervals.first {
                            let range1 = stride(from: 0.0, through: Double(firstInterval), by: 0.01)
                            for t in range1 {
                                let x = startX + CGFloat(t) * xScale
                                let y = height - CGFloat(viewModel.rememberIntervalEquation(n: 1, t: t)) * height
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            startX += CGFloat(firstInterval) * xScale
                        }

                        // 나머지 구간 처리
                        var n: Double = 2
                        for interval in intervals.dropFirst() {
                            let range = stride(from: 0.0, through: Double(interval), by: 0.01)
                            for t in range {
                                let x = startX + CGFloat(t) * xScale
                                let y = height - CGFloat(viewModel.rememberIntervalEquation(n: n, t: t)) * height
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            startX += CGFloat(interval) * xScale
                            n += 1
                        }

                        // 마지막 구간 처리
                        let range2 = stride(from: 0.0, through: Double(viewModel.dateIntervalsLastTarget()), by: 0.01)
                        for t in range2 {
                            let x = startX + CGFloat(t) * xScale
                            let y = height - CGFloat(viewModel.rememberIntervalEquation(n: n, t: t)) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        startX += CGFloat(lastIndex) * xScale
                    }
                    .stroke(Color.black, lineWidth: 1.5)
                }
            }
            .frame(width: .deviceWidth - 48, height: 180, alignment: .center)
            .clipped()
            .padding(.horizontal, 16)
        }
    }
    var rememberIntervalGraph: some View {
        VStack {
            HStack(spacing: 0) {
                Text("기억 주기")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex:"666666"))
                    .padding(.trailing, 6)
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(Color(hex:"666666"))
                    .fontWeight(.bold)
                    .onTapGesture {
                        withAnimation {
                            viewModel.addDate()
                        }
                    }
                Text("<날짜 보기>")
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: self.isNameVisible ? "28A745" : "999999"))
                    .padding(.leading, 12)
                    .onTapGesture {
                        withAnimation {
                            self.isNameVisible.toggle()
                        }
                    }
                Spacer()
                Text("캘린더")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: self.viewModel.isCalendarAccessEnabled ? "28A745" : "999999"))
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.3)) {
                            self.viewModel.isCalendarAccessEnabled.toggle()
                        }
                    }
                if self.viewModel.isCalendarAccessEnabled {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(Color(hex: self.viewModel.isCalendarAccessEnabled ? "28A745" : "999999"))
                        .padding(.leading, 2)
                        .padding(.trailing, 4)
                } else {
                    Spacer().frame(width: 8)
                }
                Text("미리알림")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: self.viewModel.isReminderAccessEnabled ? "28A745" : "999999"))
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.3)) {
                            self.viewModel.isReminderAccessEnabled.toggle()
                        }
                    }
                if self.viewModel.isReminderAccessEnabled {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(Color(hex: self.viewModel.isReminderAccessEnabled ? "28A745" : "999999"))
                        .padding(.leading, 2)
                        .padding(.trailing, 16)
                } else {
                    Spacer().frame(width: 16)
                }
            }
            .padding(.top, 16)
        }
        .padding(.leading, 16)
    }
    var rememberIntervalVerticalLine: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .top) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 16, height: 1)
                            .foregroundStyle(.white)
                            .id(0)
                        ForEach(0..<viewModel.rememberRepeatDates.count, id:\.self) { index in
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width: .deviceWidth / 2.5, height: 40)
                                Rectangle()
                                    .frame(width: .deviceWidth / 2.5, height: 2)
                            }
                            .frame(height: 40)
                        }
                        Spacer()
                    }
                    HStack(alignment: .bottom, spacing: 0) {
                        Rectangle()
                            .frame(width: 16, height: 1)
                            .foregroundStyle(.white)
                        ForEach(viewModel.rememberRepeatDates.indices, id:\.self) { index in
                            RememberPointView(isNameVisible: $isNameVisible, positionStream: $positionStream, index: index)
                                .environment(viewModel)
                            if index <= viewModel.dateIntervals().count-1 {
                                Text("\(viewModel.dateIntervals()[index])Day")
                                    .foregroundColor(.black58)
                                    .font(.pretendard(size: 12, weight: .regular))
                                    .padding(.bottom, 8)
                                    .padding(.horizontal, 16)
                                    .overlay {
                                        Text("\(viewModel.dateIntervalsFirstTarget()[index])Day")
                                            .foregroundColor(.black87)
                                            .font(.pretendard(size: 12, weight: .regular))
                                            .padding(.bottom, 58)
                                    }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    var rememberNameField: some View {
        @Bindable var bindingViewModel = viewModel
        return VStack(alignment: .leading, spacing: 0) {
            Text("기억 제목")
                .font(.pretendard(size: 14, weight: .regular))
                .foregroundStyle(Color(hex:"666666"))
                .padding(.top, 16)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(Color(hex:"DDDDDD"))
                TextField("기억할 이름을 입력하세요.", text: $bindingViewModel.rememberThisName)
                    .padding(.horizontal, 16)
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundStyle(Color(hex:"333333"))
            }
            .frame(width: .deviceWidth - 32, height: 50)
            .padding(.top, 8)
        }
        .padding(.leading, 16)
    }
    var rememberDescriptionField: some View {
        @Bindable var bindingViewModel = viewModel
        return VStack(alignment: .leading, spacing: 0) {
            Text("기억 설명")
                .font(.pretendard(size: 14, weight: .regular))
                .foregroundStyle(Color(hex:"666666"))
                .padding(.top, 16)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(Color(hex:"DDDDDD"))
                TextEditor(text: $bindingViewModel.rememberThisDescription)
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundStyle(Color(hex:"333333"))
                    .padding(12)
                if viewModel.rememberThisDescription.isEmpty {
                    Text("기억에 대한 설명을 입력하세요.")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex:"CCCCCC"))
                        .padding(12)
                        .padding(.leading, 5)
                        .padding(.top, 8)
                }
            }
            .frame(width: .deviceWidth - 32, height: 250)
            .padding(.top, 8)
        }
        .padding(.leading, 16)
    }
    struct RememberPointView: View {
        @Environment(RememberThisAddViewModel.self) var viewModel: RememberThisAddViewModel
        @Binding var positionStream: PassthroughSubject<(index: Int, position: CGPoint), Never>
        @State private var index: Int
        @State private var isKeyboardVisible: Bool = false
        @State private var isShowingDialog: Bool = false
        @State private var isFirstIndexDeleteAlert: Bool = false
        init(isNameVisible: Binding<Bool>, positionStream: Binding<PassthroughSubject<(index: Int, position: CGPoint), Never>>, index: Int) {
            self._isNameVisible = isNameVisible
            self._positionStream = positionStream
            self.index = index
        }
        @State private var tapPosition: CGPoint = .zero
        @Binding private var isNameVisible: Bool
        var body: some View {
            VStack(spacing: 8) {
                Circle()
                    .frame(width: 12, height: 12)
                    .padding(.top, (40 - 12)/2)
                    .foregroundColor(.gray)
                if isNameVisible && index < viewModel.rememberRepeatDates.count {
                    Text(viewModel.rememberRepeatDates[index].formmatToString("yyyy년 MM월 dd일"))
                        .foregroundColor(.gray)
                        .font(.pretendard(size: 12, weight: .regular))
                        .minimumScaleFactor(0.5)
                } else {
                    Text(" ")
                        .foregroundColor(.gray)
                        .font(.pretendard(size: 12, weight: .regular))
                        .minimumScaleFactor(0.5)
                }
            }
            .onLongPressGesture {
                if index == 0 {
                    isFirstIndexDeleteAlert = true
                } else {
                    isShowingDialog = true
                }
            }
            .observeKeyboardState(isKeyboardVisible: $isKeyboardVisible)
            .alert("삭제 불가", isPresented: $isFirstIndexDeleteAlert) {
                Button("확인", role: .cancel) { isFirstIndexDeleteAlert = false }
            } message: {
                Text("시작날짜는 삭제할 수 없습니다.")
            }
            .confirmationDialog("날짜 삭제", isPresented: $isShowingDialog) {
                Button("삭제", role: .destructive) {
                    withAnimation {
                        if index < viewModel.rememberRepeatDates.count {
                            viewModel.removeDate(index)
                        }
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                if index < viewModel.rememberRepeatDates.count {
                    Text("\(viewModel.rememberRepeatDates[index].formmatToString("yyyy년 MM월 dd일"))를 삭제합니다.")
                }
            }
            .background(Color.white.opacity(0.0000001))
            .onTapGesture {
                if isKeyboardVisible {
                    self.hideKeyboard()
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        self.positionStream.send((index, tapPosition))
                    }
                } else {
                    self.positionStream.send((index, tapPosition))
                }
            }
            .background(
                GeometryReader { geometry in
                    let global = geometry.frame(in: .global)
                    Color.clear
                        .onAppear {
                            tapPosition = global.origin
                        }
                        .onChange(of: global) { oldValue, newValue in
                            tapPosition = newValue.origin
                        }
                }
            )
        }
    }
}
#Preview {
    NavigationView {
        RememberThisAddView()
    }
}
