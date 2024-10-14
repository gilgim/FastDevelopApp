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
    @State var focusIndex: Int = 0
    var body: some View {
        NavigationStack {
            ZStack {
                if vm.rememberThisComponents.count > 0 {
                    ACarousel(vm.rememberThisComponents,
                              id: \.originModel.id,
                              index: $focusIndex,
                              spacing: 20,
                              headspace: 20,
                              isWrap: true,
                              autoScroll: .inactive) { rememberThis in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(rememberThis.name)
                                    .font(.pretendard(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.black87)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.7)
                                    .padding(.top, 16)
                                Spacer()
                                Text(rememberThis.completePertage)
                                    .font(.pretendard(size: 38, weight: .semibold))
                                    .foregroundStyle(Color.black87)
                                    .padding(.trailing, 24)
                                    .padding(.top, 16)
                            }
                            .frame(height: 80, alignment: .center)
                            .padding(.bottom, 10)
                            Text(rememberThis.createdAt)
                                .font(.tenada(size: 12))
                                .foregroundStyle(Color.black58)
                            Spacer().frame(height: 24)
                            ForEach(rememberThis.dateComponents, id: \.originModel.id) { dateComponent in
                                HStack {
                                    Image(systemName: dateComponent.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(dateComponent.color)
                                        .frame(width: 20, height: 20)
                                    Text(dateComponent.koreanScheduleText)
                                        .font(.pretendard(size: 18, weight: .bold))
                                        .foregroundStyle(dateComponent.color)
                                    VStack {
                                        Spacer()
                                        Text(dateComponent.date)
                                            .font(.pretendard(size: 12, weight: .semibold))
                                            .foregroundStyle(dateComponent.color)
                                    }
                                    .frame(height: 16)
                                }
                                .strikethrough(dateComponent.strikeThrough, color: dateComponent.color)
                                .padding(.bottom, 13)
                                .onTapGesture {
                                    vm.remeberThis(dateComponent.originModel)
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
                        self.selected = rememberThis.originModel
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
        .onAppear() {
            vm.loadRememberSchedules()
        }
    }
}

#Preview {
    RememberThisListView()
}
