//
//  ListViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation

@Observable
class ListViewModel {
    var remembers: [RememberModel] = []
    
    @MainActor
    func deleteRemember(_ rememberThis: RememberModel) {
        RememberThisConfiguration.context.delete(rememberThis)  // 데이터 삭제
        try? RememberThisConfiguration.context.save()  // 변경 사항 저장
    }
}
