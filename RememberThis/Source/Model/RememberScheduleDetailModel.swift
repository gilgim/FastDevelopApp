//
//  RememberScheduleDetailModel.swift
//  RememberThis
//
//  Created by gaea on 10/14/24.
//
import SwiftData
import Foundation

@Model
class RememberScheduleDetailModel {
    var id: UUID
    var calendarID: String?
    var reminderID: String?
    var date: Date
    var completeDate: Date?
    @Relationship var rememberThis: RememberScheduleModel?
    init(id: UUID, calendarID: String? = nil, reminderID: String? = nil, date: Date, completeDate: Date? = nil) {
        self.id = id
        self.calendarID = calendarID
        self.reminderID = reminderID
        self.date = date
        self.completeDate = completeDate
    }
}
