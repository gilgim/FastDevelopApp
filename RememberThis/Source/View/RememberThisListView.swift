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
    @Query(sort: \RememberModel.id) var rememberThises: [RememberModel]
    var vm = RememberThisListViewModel()
    @State var selected: RememberModel?
    @State var isDeletePresented: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
//                if rememberThises.count > 0 {
//                    ACarousel(rememberThises,
//                              id: \.id,
//                              spacing: 20,
//                              autoScroll: .inactive) { rememberThis in
//                        ZStack {
//                            Spacer()
//                            Text("\(rememberThis.rememberName)")
//                        }
//                        .background(Color.brown)
//                        .frame(height: 500)
//                    }
//                              .background(Color.brown)
//                } else {
//                    Text("Empty View")
//                }
                ACarousel(["Text", "Text"],
                          id: \.self,
                          spacing: 20,
                          isWrap: true,
                          autoScroll: .inactive) { rememberThis in
                    ZStack {
                        Spacer()
                        Text("\(rememberThis)")
                    }
                    .frame(width: 300, height: 500)
                    .background(Color.red)
                }
                .background(Color.brown)
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
                    RememberThisAddView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    RememberThisListView()
}
