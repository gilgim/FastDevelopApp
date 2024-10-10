//
//  AddView.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectDateIndex: Int?
    @State var vm = AddViewModel()
    var body: some View {
        @Bindable var bindingVm = vm
        VStack {
            TextField("암기명", text: $bindingVm.rememberThisName)
                .padding(.leading, 24)
            TextEditor(text: $bindingVm.rememberThisDescription)
                .frame(height: 100)
                .padding(.leading, 24)
            List {
                Button("일정 추가") {
                    vm.addDate()
                }
                ForEach(0..<vm.rememberRepeatDates.count, id: \.self) { index in
                    let dateText = vm.dateFormatterString(date: vm.rememberRepeatDates[index])
                    Button(dateText) {
                        self.selectDateIndex = index
                    }
                }
            }
        }
        .toolbar {
            Button("Ok") {
                Task {
                    self.vm.createRemember()
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
    AddView()
}
