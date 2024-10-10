//
//  RememberModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftData
import Foundation

@Model
class RememberModel {
    var id: UUID
    var rememberName: String
    var rememberDescription: String
    @Relationship(inverse: \RemeberDateModel.rememberThis) var rememberDates: [RemeberDateModel]
    init(id: UUID, rememberName: String, rememberDescription: String, rememberDates: [RemeberDateModel]) {
        self.id = id
        self.rememberName = rememberName
        self.rememberDescription = rememberDescription
        self.rememberDates = rememberDates
    }
}
@Model
class RemeberDateModel {
    var id: UUID
    @Relationship var rememberThis: RememberModel?
    init(id: UUID, rememberThis: RememberModel? = nil) {
        self.id = id
        self.rememberThis = rememberThis
    }
}
