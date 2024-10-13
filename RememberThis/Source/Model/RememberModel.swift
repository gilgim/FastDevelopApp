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
    var createDate: Date
    @Relationship(inverse: \RememberDateModel.rememberThis) var rememberDates: [RememberDateModel]?
    init(id: UUID, rememberName: String, rememberDescription: String, createData: Date) {
        self.id = id
        self.rememberName = rememberName
        self.rememberDescription = rememberDescription
        self.createDate = createData
    }
}
@Model
class RememberDateModel {
    var id: UUID
    var calendarID: String?
    var reminderID: String?
    var date: Date
    var completeDate: Date?
    @Relationship var rememberThis: RememberModel?
    init(id: UUID, calendarID: String? = nil, reminderID: String? = nil, date: Date, completeDate: Date? = nil) {
        self.id = id
        self.calendarID = calendarID
        self.reminderID = reminderID
        self.date = date
        self.completeDate = completeDate
    }
}
