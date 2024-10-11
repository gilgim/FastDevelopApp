//
//  ListView.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI
import SwiftData
struct ListView: View {
    @Query(sort: \RememberModel.id) var rememberThises: [RememberModel]
    var vm = ListViewModel()
    @State var selected: RememberModel?
    @State var isDeletePresented: Bool = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(rememberThises, id:\.id) { rememberThis in
                    Text(rememberThis.rememberName + "암기수 \(rememberThis.rememberDates?.count ?? 0)")
                        .swipeActions {
                            Button {
                                selected = rememberThis
                                isDeletePresented.toggle()
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
                            }
                        }
                }
            }
            .alert("삭제", isPresented: $isDeletePresented, actions: {
                Button("취소", role: .cancel) {
                    selected = nil
                }
                Button("삭제", role: .destructive) {
                    if let selected {
                        vm.deleteRemember(selected)
                    }
                }
            })
            .toolbar {
                NavigationLink {
                    AddView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    ListView()
}
