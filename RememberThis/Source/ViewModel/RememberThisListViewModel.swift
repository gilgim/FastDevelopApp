//
//  RememberThisListViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation
import EventKit
import UserNotifications
import SwiftUI
@Observable
class RememberThisListViewModel {
    struct RememberThisComponent {
        enum ReminderStatus {
            case overdue
            case incomplete
            case complete
            case earlyComplete
            case lateComplete
        }
        var originModel: RememberScheduleModel
        var name: String
        var createdAt: String
        var completePertage: String
        var dateComponents: [RememberThisDateComponent]
        struct RememberThisDateComponent {
            var imageName: String
            var date: String
            var koreanScheduleText: String
            var status: ReminderStatus
            var originModel: RememberScheduleDetailModel
            var color: Color
            var strikeThrough: Bool
        }
    }
    var rememberThisComponents: [RememberThisComponent] = []
    @MainActor
    func loadRememberSchedules() {
        rememberThisComponents = []
        let schedules = RememberThisSwiftDataConfiguration.loadData(RememberScheduleModel.self) ?? []
        for schedule in schedules {
            let createAt = schedule.creationDate.formmatToString("yyyy년 MM월 dd일 HH시 mm분 부터")
            var dateComponents: [RememberThisComponent.RememberThisDateComponent] = []
            let rememberDates = schedule.rememberDates ?? []
            var completeCount = 0
            for (index, rememberDate) in rememberDates.enumerated() {
                //  미리알림 있으면 동기화해야한다.
                let eventStore = EKEventStore()
                if let reminderID = rememberDate.reminderID,
                   let reminder = eventStore.calendarItem(withIdentifier: reminderID) as? EKReminder {
                    rememberDate.completeDate = reminder.completionDate
                    try? RememberThisSwiftDataConfiguration.context.save()
                }
                if rememberDate.completeDate != nil {
                    completeCount += 1
                }
                let koreanScheduleText = (repetitionDictionary["repeat\(index+1)"] ?? "") + " 암기"
                //  완료: 미리완료, 늦게완료, 완벽완료
                var dateComponent = RememberThisComponent.RememberThisDateComponent(imageName: "", date: rememberDate.date.formmatToString("yyyy.MM.dd"), koreanScheduleText: koreanScheduleText, status: .incomplete, originModel: rememberDate, color: .clear, strikeThrough: false)
                if let completeDate = rememberDate.completeDate {
                    dateComponent.strikeThrough = true
                    if completeDate > rememberDate.date {
                        dateComponent.imageName = "exclamationmark.square"
                        dateComponent.status = .lateComplete
                        dateComponent.color = .yellow
                    } else if completeDate == rememberDate.date {
                        dateComponent.imageName = "checkmark.square.fill"
                        dateComponent.status = .complete
                        dateComponent.color = .green
                    } else if completeDate < rememberDate.date {
                        dateComponent.imageName = "exclamationmark.square"
                        dateComponent.status = .earlyComplete
                        dateComponent.color = .yellow
                    }
                } else {
                    dateComponent.strikeThrough = false
                    if rememberDate.date < Date() {
                        dateComponent.imageName = "multiply.square"
                        dateComponent.status = .overdue
                        dateComponent.color = .red
                    } else {
                        dateComponent.imageName = "square"
                        dateComponent.status = .incomplete
                        dateComponent.color = .black58
                    }
                }
                dateComponents.append(dateComponent)
            }
            let completePertage = Int(Double(completeCount)/Double(rememberDates.count) * 100)
            
            let rememberThisComponent = RememberThisComponent(originModel: schedule, name: schedule.scheduleName, createdAt: createAt, completePertage: "\(completePertage)%", dateComponents: dateComponents)
            self.rememberThisComponents.append(rememberThisComponent)
        }
    }
    @MainActor
    func deleteRemember(_ rememberThis: RememberScheduleModel) {
        for rememberDate in rememberThis.rememberDates ?? [] {
            let identifier = "\(rememberDate.id)"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let isDeleted = !requests.contains { $0.identifier == identifier }
                if isDeleted {
                    print("알림이 성공적으로 삭제되었습니다.")
                } else {
                    print("알림 삭제에 실패했습니다.")
                }
            }
            
            if let calendarID = rememberDate.calendarID {
                let eventStore = EKEventStore()
                let event = eventStore.event(withIdentifier: calendarID)
                if let event = event {
                    do {
                        try eventStore.remove(event, span: .thisEvent)
                        print("캘린더 이벤트가 삭제되었습니다.")
                    } catch let error {
                        print("이벤트 삭제 실패: \(error)")
                    }
                } else {
                    print("해당 ID로 이벤트를 찾을 수 없습니다.")
                }
            }
            if let reminderID = rememberDate.reminderID {
                let eventStore = EKEventStore()
                let reminder = eventStore.calendarItem(withIdentifier: reminderID) as? EKReminder
                if let reminder = reminder {
                    do {
                        try eventStore.remove(reminder, commit: true)
                        print("미리알림이 삭제되었습니다.")
                    } catch let error {
                        print("미리알림 삭제 실패: \(error)")
                    }
                } else {
                    print("해당 ID로 미리알림을 찾을 수 없습니다.")
                }
            }
            RememberThisSwiftDataConfiguration.context.delete(rememberDate)
        }
        RememberThisSwiftDataConfiguration.context.delete(rememberThis)  // 데이터 삭제
        try? RememberThisSwiftDataConfiguration.context.save()  // 변경 사항 저장
        self.loadRememberSchedules()
    }
    @MainActor
    func remeberThis(_ model: RememberScheduleDetailModel) {
        let eventStore = EKEventStore()
        if let reminderID = model.reminderID,
           let reminder = eventStore.calendarItem(withIdentifier: reminderID) as? EKReminder {
            if reminder.completionDate == nil {
                reminder.completionDate = Date()
            } else {
                reminder.completionDate = nil
            }
            try? eventStore.save(reminder, commit: true)
        } else {
            if model.completeDate == nil {
                model.completeDate = Date()
            } else {
                model.completeDate = nil
            }
            try? RememberThisSwiftDataConfiguration.context.save()
        }
        self.loadRememberSchedules()
    }
}
