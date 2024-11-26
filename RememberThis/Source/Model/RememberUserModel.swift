//
//  RememberUserModel.swift
//  RememberThis
//
//  Created by gaea on 11/26/24.
//

import SwiftData
import Foundation

@Model
class RememberUserModel {
    var id: UUID
    var age: Int
    var memoryLevel: Int
    init(id: UUID, age: Int, memoryLevel: Int) {
        self.id = id
        self.age = age
        self.memoryLevel = memoryLevel
    }
}
