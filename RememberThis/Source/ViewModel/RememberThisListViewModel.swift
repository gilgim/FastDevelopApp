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
    struct RememberThisForView: Hashable {
        let id: UUID = .init()
        let name: String
        let createdDateText: String
        let achievement: String
        let isFail: Bool
        let achievementListTexts: [String]?
        let achievementPlanListTexts: [String]?
        let todayRememberDate: Date?
        let original: RememberScheduleModel
    }
    var rememberThisForViews: [RememberThisForView] = []
    private var selectRememberThis: RememberScheduleModel? = nil
    
    func selectRememberThis(_ content: RememberThisForView) {
        self.selectRememberThis = content.original
    }
    @MainActor
    func loadRememberSchedules() {
        self.rememberThisForViews = []
        
        var schedules = RememberThisSwiftDataConfiguration.loadData(RememberScheduleModel.self) ?? []
        schedules.sort(by: {$0.creationDate > $1.creationDate})
        
        for schedule in schedules {
            let contentName = schedule.scheduleName
            let createdDateText = schedule.creationDate.formmatToString("yyyy년 MM월 dd일")
            let achievementText = "\(rememberThisAchievement(schedule))%"
            let isFail = rememberThisFail(schedule)
            let achievementListTexts = rememberThisAchievementListTexts(schedule)
            let achievementPlanListTexts = rememberThisAchievementPlanListTexts(schedule)
            let todayRememberDate = rememberThisTodayDate(schedule)
            let remeberThisForView: RememberThisForView = .init(name: schedule.scheduleName,
                                                                createdDateText: createdDateText,
                                                                achievement: achievementText,
                                                                isFail: isFail,
                                                                achievementListTexts: achievementListTexts,
                                                                achievementPlanListTexts: achievementPlanListTexts,
                                                                todayRememberDate: todayRememberDate,
                                                                original: schedule)
            self.rememberThisForViews.append(remeberThisForView)
        }
    }
    
    func rememberThisAchievement(_ rememberThis: RememberScheduleModel) -> Int {
        let totalCount = rememberThis.rememberDates?.count ?? 0
        var achievement: Int = 0
        for remeberDate in rememberThis.rememberDates ?? [] {
            if remeberDate.completeDate != nil {
                achievement += 1
            }
        }
        return Int(achievement / totalCount * 100)
    }
    func rememberThisAchievementListTexts(_ rememberThis: RememberScheduleModel) -> [String]? {
        var achievementListTexts: [String] = []
        for remeberDate in rememberThis.rememberDates ?? [] {
            if remeberDate.completeDate != nil {
                achievementListTexts.append(remeberDate.date.formmatToString("- yyyy년 MM월 dd일 완료"))
            }
        }
        if achievementListTexts.isEmpty {
            return nil
        } else {
            return achievementListTexts
        }
    }
    func rememberThisAchievementPlanListTexts(_ rememberThis: RememberScheduleModel) -> [String]? {
        var achievementPlanListTexts: [String] = []
        for remeberDate in rememberThis.rememberDates ?? [] {
            if remeberDate.date.isAfterDay(Date()) {
                achievementPlanListTexts.append(remeberDate.date.formmatToString("- yyyy년 MM월 dd일 예정"))
            }
        }
        if achievementPlanListTexts.isEmpty {
            return nil
        } else {
            return achievementPlanListTexts
        }
    }
    func rememberThisFail(_ rememberThis: RememberScheduleModel) -> Bool {
        let calendar = Calendar.current
        for remeberDate in rememberThis.rememberDates ?? [] {
            if remeberDate.date.isBeforeDay(Date()) {
                if remeberDate.completeDate == nil {
                    return true
                }
            }
        }
        return false
    }
    func rememberThisTodayDate(_ rememberThis: RememberScheduleModel) -> Date? {
        for rememberDate in rememberThis.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                return rememberDate.date
            }
        }
        return nil
    }
    @MainActor
    func deleteRemember() {
        guard let selectRememberThis else { return }
        for rememberDate in selectRememberThis.rememberDates ?? [] {
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
        RememberThisSwiftDataConfiguration.context.delete(selectRememberThis)  // 데이터 삭제
        try? RememberThisSwiftDataConfiguration.context.save()  // 변경 사항 저장
        self.loadRememberSchedules()
        self.selectRememberThis = nil
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
