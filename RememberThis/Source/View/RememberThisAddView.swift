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
                        DatePicker("", selection: $bindingViewModel.rememberRepeatDates[currentIndex], displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .scaleEffect(0.7)
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
                self.tapPosition = value.position
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
            Button("Ok") {
                Task {
                    await self.viewModel.createRemember()
                    self.dismiss()
                }
            }
        }
    }
    var rememberGraph: some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: 2)
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: .deviceWidth, y: 250))
                path.move(to: CGPoint(x: .deviceWidth, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 250))
                path.closeSubpath()
            }
            .stroke(Color.black, lineWidth: 2)
        }
        .frame(width: .deviceWidth, height: 250)
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
                        viewModel.addDate()
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
    @State private var isNameVisible: Bool = false
    var rememberIntervalVerticalLine: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .top) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 16, height: 1)
                            .foregroundStyle(.white)
                            .id(0)
                        ForEach(0..<maxLineCount, id:\.self) { index in
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width: .deviceWidth, height: 20)
                                Rectangle()
                                    .frame(width: .deviceWidth, height: 2)
                            }
                            .frame(height: 20)
                            .onTapGesture {
                                withAnimation {
                                    self.isNameVisible.toggle()
                                    if !self.isNameVisible {
                                        proxy.scrollTo(0, anchor: .trailing)
                                    }
                                }
                            }
                            
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
                            if !(index == viewModel.rememberRepeatDates.count - 1) {
                                Text("3Day")
                                    .foregroundColor(.gray)
                                    .font(.pretendard(size: 12, weight: .regular))
                                    .padding(.bottom, 8)
                                    .padding(.horizontal, 16)
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
                    .padding(.top, (20 - 12)/2)
                    .foregroundColor(.gray)
                if isNameVisible {
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
            .background(Color.white.opacity(0.0000001))
            .onTapGesture {
                self.positionStream.send((index, tapPosition))
            }
            .background(
                GeometryReader { geometry in
                    let global = geometry.frame(in: .global)
                    Color.clear
                        .onAppear {
                            tapPosition = global.origin
                            print(global.origin)
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
    RememberThisAddView()
}
