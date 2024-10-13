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
    @Query(sort: \RememberModel.createDate, order: .reverse) var rememberThises: [RememberModel]
    var vm = RememberThisListViewModel()
    @State var isShowMask: Bool = true
    @State var selected: RememberModel?
    @State var isDeletePresented: Bool = false
    @State var focusIndex: Int = 0
    @State var test: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                if rememberThises.count > 0 {
                    ACarousel(rememberThises,
                              id: \.id,
                              index: $focusIndex,
                              spacing: 20,
                              headspace: 20,
                              isWrap: true,
                              autoScroll: .inactive) { rememberThis in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("\(rememberThis.rememberName)")
                                    .font(.pretendard(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.black87)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.7)
                                    .padding(.top, 16)
                                Spacer()
                                Text("38%")
                                    .font(.pretendard(size: 38, weight: .semibold))
                                    .foregroundStyle(Color.black87)
                                    .padding(.trailing, 24)
                                    .padding(.top, 16)
                            }
                            .frame(height: 80, alignment: .center)
                            .padding(.bottom, 10)
                            Text("\(vm.createDateText(rememberThis))")
                                .font(.tenada(size: 12))
                                .foregroundStyle(Color.black58)
                            Spacer().frame(height: 24)
                            if let rememberDates = rememberThis.rememberDates {
                                ForEach(Array(rememberDates.enumerated()), id: \.element.id) { index, rememberDate in
                                    HStack {
                                        let rememberStatus = vm.rememberDateCheck(rememberDate)
                                        if rememberStatus == .complete {
                                            Image(systemName: "checkmark.square.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color.green)
                                                .frame(width: 20, height: 20)
                                            if let repeatText = repetitionDictionary["repeat\(index+1)"] {
                                                Text(repeatText + " 암기")
                                                    .font(.pretendard(size: 18, weight: .bold))
                                                    .foregroundStyle(Color.green)
                                                    .strikethrough(true, color: .black)
                                            }
                                            VStack {
                                                Spacer()
                                                Text(vm.rememberDateText(rememberDate))
                                                    .font(.pretendard(size: 12, weight: .semibold))
                                                    .foregroundStyle(Color.green)
                                            }
                                            .frame(height: 16)
                                        } else if rememberStatus == .incomplete {
                                            Image(systemName: "square")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color.black58)
                                                .frame(width: 20, height: 20)
                                            if let repeatText = repetitionDictionary["repeat\(index+1)"] {
                                                Text(repeatText + " 암기")
                                                    .font(.pretendard(size: 18, weight: .bold))
                                                    .foregroundStyle(Color.black58)
                                            }
                                            VStack {
                                                Spacer()
                                                Text(vm.rememberDateText(rememberDate))
                                                    .font(.pretendard(size: 12, weight: .semibold))
                                                    .foregroundStyle(Color.black58)
                                            }
                                            .frame(height: 16)
                                        } else if rememberStatus == .overdue {
                                            Image(systemName: "multiply.square")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color.red)
                                                .frame(width: 20, height: 20)
                                            if let repeatText = repetitionDictionary["repeat\(index+1)"] {
                                                Text(repeatText + " 암기")
                                                    .font(.pretendard(size: 18, weight: .bold))
                                                    .foregroundStyle(Color.red)
                                            }
                                            VStack {
                                                Spacer()
                                                Text(vm.rememberDateText(rememberDate))
                                                    .font(.pretendard(size: 12, weight: .semibold))
                                                    .foregroundStyle(Color.red)
                                            }
                                            .frame(height: 16)
                                        } else if rememberStatus == .urgent {
                                            Image(systemName: "exclamationmark.square")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color.yellow)
                                                .frame(width: 20, height: 20)
                                            if let repeatText = repetitionDictionary["repeat\(index+1)"] {
                                                Text(repeatText + " 암기")
                                                    .font(.pretendard(size: 18, weight: .bold))
                                                    .foregroundStyle(Color.yellow)
                                                    .strikethrough(true, color: .black)
                                            }
                                            VStack {
                                                Spacer()
                                                Text(vm.rememberDateText(rememberDate))
                                                    .font(.pretendard(size: 12, weight: .semibold))
                                                    .foregroundStyle(Color.yellow)
                                            }
                                            .frame(height: 16)
                                        }
                                        Spacer()
                                    }
                                    .padding(.bottom, 13)
                                    .onTapGesture {
                                        vm.rememberDateOk(rememberDate)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 24)
                        .background(Color.customSilver)
                        .cornerRadius(12)
                        .frame(width: 300, height: 500)
                        .shadow(color: .black12, radius: 12, x: 0, y: 4)
                    } bottomFirstClick: { rememberThis, index in
                        self.selected = rememberThis
                        self.focusIndex = index > 0 ? index-1 : 0
                        isDeletePresented.toggle()
                    } bottomSecondClick: { rememberThis, index in
                        
                    }
                    .background(Color.etherealBlue)
                } else {
                    Text("Empty View")
                }
            }
            .alert("삭제", isPresented: $isDeletePresented, actions: {
                Button("취소", role: .cancel) {
                    selected = nil
                }
                Button("삭제", role: .destructive) {
                    if let selected {
                        focusIndex = 0
                        vm.deleteRemember(selected)
                    }
                }
            })
            .toolbar {
                NavigationLink {
                    RememberThisAddView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    TestView()
}
struct TestView: View {
    var vm = RememberThisListViewModel()
    @State var focusIndex: Int = 0
    @State var test: Bool = false
    var body: some View {
                    ACarousel(["Test1", "Test2"],
                              id: \.self,
                              index: $focusIndex,
                              spacing: 20,
                              headspace: 20,
                              isWrap: true,
                              autoScroll: .inactive) { rememberThis in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("\(rememberThis)")
                                    .font(.pretendard(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.black87)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.7)
                                    .padding(.top, 16)
                                Spacer()
                                Text("38%")
                                    .font(.pretendard(size: 38, weight: .semibold))
                                    .foregroundStyle(Color.black87)
                                    .padding(.trailing, 24)
                                    .padding(.top, 16)
                            }
                            .frame(height: 80, alignment: .center)
                            .padding(.bottom, 10)
//                            Text("\(vm.createDateText(Date()))")
//                                .font(.tenada(size: 12))
//                                .foregroundStyle(Color.black58)
                            Spacer().frame(height: 24)
                            ScrollView {
                                HStack {
                                    Image(systemName: !test ? "square" : "checkmark.square.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color.black58)
                                        .frame(width: 20, height: 20)
                                    if let repeatText = repetitionDictionary["repeat1"] {
                                        Text(repeatText + " 암기")
                                            .font(.pretendard(size: 18, weight: .bold))
                                            .foregroundStyle(Color.black58)
                                            .strikethrough(test, color: .black)
                                    }
                                    VStack {
                                        Spacer()
                                        Text("2024.02.01")
                                            .font(.pretendard(size: 12, weight: .semibold))
                                            .foregroundStyle(Color.black58)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 13)
                                .onTapGesture {
                                    test.toggle()
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 24)
                        .background(Color.customSilver)
                        .cornerRadius(12)
                        .frame(width: 300, height: 500)
                        .shadow(color: .black12, radius: 12, x: 0, y: 4)
                    } bottomFirstClick: { rememberThis, index in
        //                self.selected = rememberThis
        //                self.focusIndex = index > 0 ? index-1 : 0
        //                isDeletePresented.toggle()
                    } bottomSecondClick: { rememberThis, index in
        
                    }
                    .background(Color.etherealBlue)
    }
}
