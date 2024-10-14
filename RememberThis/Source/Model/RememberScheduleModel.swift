//
//  RememberScheduleModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftData
import Foundation

@Model
class RememberScheduleModel {
    var id: UUID
    var scheduleName: String
    var scheduleDescription: String
    var creationDate: Date
    @Relationship(inverse: \RememberScheduleDetailModel.rememberThis) var rememberDates: [RememberScheduleDetailModel]?
    init(id: UUID, scheduleName: String, scheduleDescription: String, creationDate: Date) {
        self.id = id
        self.scheduleName = scheduleName
        self.scheduleDescription = scheduleDescription
        self.creationDate = creationDate
    }
}

