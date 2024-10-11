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
    @Relationship(inverse: \RememberDateModel.rememberThis) var rememberDates: [RememberDateModel]?
    init(id: UUID, rememberName: String, rememberDescription: String) {
        self.id = id
        self.rememberName = rememberName
        self.rememberDescription = rememberDescription
    }
}
@Model
class RememberDateModel {
    var id: UUID
    var calendarID: String?
    var reminderID: String?
    var date: Date
    @Relationship var rememberThis: RememberModel?
    init(id: UUID, calendarID: String? = nil, reminderID: String? = nil, date: Date) {
        self.id = id
        self.calendarID = calendarID
        self.reminderID = reminderID
        self.date = date
    }
}
