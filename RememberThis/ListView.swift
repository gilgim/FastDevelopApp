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
    var body: some View {
        NavigationStack {
            List {
                ForEach(rememberThises, id:\.id) { rememberThis in
                    Text(rememberThis.rememberName)
                        .swipeActions {
                            Button {
                                vm.deleteRemember(rememberThis)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
                            }
                        }
                }
            }
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
