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
        let failList: [String]?
        let achievementListTexts: [String]?
        let achievementPlanListTexts: [String]?
        let todayRememberDateText: String?
        let original: RememberScheduleModel
    }
    var rememberThisForViews: [RememberThisForView] = []
    private var selectRememberThis: RememberScheduleModel? = nil
    func reviewReviewComplete() {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                if let recallLevel = rememberDate.recallLevel,
                   let reviewSatisfaction = rememberDate.reviewSatisfaction {
                    rememberDate.recallLevel = recallLevel
                    rememberDate.reviewSatisfaction = reviewSatisfaction
                }
                break
            }
        }
        Task { @MainActor in
            let dataList = RememberThisSwiftDataConfiguration.loadData(RememberScheduleDetailModel.self) ?? []
            //  한달 치 데이터
            if dataList.count > 31 {
                let userDatas = RememberThisSwiftDataConfiguration.loadData(RememberUserModel.self) ?? []
                guard let userData = userDatas.first else {return}
                let tensorFlowLiteManager = TensorFlowLiteManager()
                tensorFlowLiteManager.loadModel()
                
                for (i, data) in dataList.enumerated() {
                    let repeatEffect = 1 * 0.75
                    let memoryLevelNormalized = Double(userData.memoryLevel) / 5.0
                    let ageNormalized = Double(userData.age) / 5.0
                    if i > 0 {
                        let expectedOutput = dataList[i - 1]
                        tensorFlowLiteManager.train(inputData: [Float32(dataList.count), Float32(memoryLevelNormalized), Float32(ageNormalized), Float32(repeatEffect)], expectedOutput: Float32(expectedOutput.recallLevel ?? 0))
                    }
                }
            }
        }
    }
    func selectRememberThis(_ content: RememberThisForView) {
        self.selectRememberThis = content.original
    }
    func reviewComplete() {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                rememberDate.completeDate = Date()
                rememberDate.recallLevel = 3
                rememberDate.reviewSatisfaction = 3
                break
            }
        }
        Task { @MainActor in
            self.loadRememberSchedules()
        }
    }
    func reviewCompleteCancel() {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                rememberDate.recallLevel = nil
                rememberDate.reviewSatisfaction = nil
                break
            }
        }
    }
    func isSelectRecallLevel(value: Int) -> Bool {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                if Int(rememberDate.recallLevel ?? 0) == value {
                    return true
                }
            }
        }
        return false
    }
    func selectRecallLevel(value: Int) {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                rememberDate.recallLevel = Double(value)
                return
            }
        }
    }
    func isSelectReviewSatisfaction(value: Int) -> Bool {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                if Int(rememberDate.reviewSatisfaction ?? 0) == value {
                    return true
                }
            }
        }
        return false
    }
    func selectReviewSatisfaction(value: Int) {
        for rememberDate in self.selectRememberThis?.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) {
                rememberDate.reviewSatisfaction = Double(value)
                return
            }
        }
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
            let failList = rememberThisFailList(schedule)
            let achievementListTexts = rememberThisAchievementListTexts(schedule)?.sorted(by: {$0 < $1})
            let achievementPlanListTexts = rememberThisAchievementPlanListTexts(schedule)?.sorted(by: {$0 < $1})
            let todayRememberDateText = rememberThisTodayDate(schedule)?.formmatToString("yyyy년 MM월 dd일")
            let remeberThisForView: RememberThisForView = .init(name: contentName,
                                                                createdDateText: createdDateText,
                                                                achievement: achievementText,
                                                                isFail: isFail,
                                                                failList: failList,
                                                                achievementListTexts: achievementListTexts,
                                                                achievementPlanListTexts: achievementPlanListTexts,
                                                                todayRememberDateText: todayRememberDateText,
                                                                original: schedule)
            self.rememberThisForViews.append(remeberThisForView)
        }
    }
    
    func rememberThisAchievement(_ rememberThis: RememberScheduleModel) -> Int {
        guard let totalCount = rememberThis.rememberDates?.count, totalCount > 0 else {return 0}
        var achievement: Double = 0
        for remeberDate in rememberThis.rememberDates ?? [] {
            if remeberDate.completeDate != nil {
                achievement += 1
            }
        }
        return Int(achievement / Double(totalCount) * 100)
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
        for remeberDate in rememberThis.rememberDates ?? [] {
            if remeberDate.date.isBeforeDay(Date()) {
                if remeberDate.completeDate == nil {
                    return true
                }
            }
        }
        return false
    }
    func rememberThisFailList(_ rememberThis: RememberScheduleModel) -> [String]? {
        if rememberThisFail(rememberThis) {
            var failDateListText: [String] = []
            for remeberDate in rememberThis.rememberDates ?? [] {
                if remeberDate.date.isBeforeDay(Date()) {
                    if remeberDate.completeDate == nil {
                        let failText = remeberDate.date.formmatToString("yyyy년 MM월 dd일 일정 실패")
                        failDateListText.append(failText)
                    }
                }
            }
            return failDateListText
        } else {
            return nil
        }
    }
    func rememberThisTodayDate(_ rememberThis: RememberScheduleModel) -> Date? {
        for rememberDate in rememberThis.rememberDates ?? [] {
            if rememberDate.date.isSameDay(as: Date()) && rememberDate.completeDate == nil {
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
    func rememberGiveUp() {
        deleteRemember()
    }
    @MainActor
    func rememberTry() async {
        guard let selectRememberThis else { return }
        let rememberThisName = selectRememberThis.scheduleName
        let rememberThisDescription = selectRememberThis.scheduleDescription
        var newDates: [Date] = [Date()]
        var isCalendarAccessEnabled = false
        
        var rememberDates = selectRememberThis.rememberDates ?? []
        rememberDates.sort(by: {$0.date < $1.date})
        
        var isReminderAccessEnabled = false
        for rememberDate in rememberDates {
            if rememberDate.calendarID != nil {
                isCalendarAccessEnabled = true
            }
            if rememberDate.reminderID != nil {
                isReminderAccessEnabled = true
            }
            if rememberDates[0].date != rememberDate.date {
                let differenceInDay = rememberDates[0].date.differenceInDays(to: rememberDate.date)
                newDates.append(Date().addingDays(differenceInDay))
            }
        }
        var rememberDate: [RememberScheduleDetailModel] = []
        for date in newDates {
            let rememberDateID = UUID()
            let rememberDateModel = RememberScheduleDetailModel(id: rememberDateID, date: date)
            self.addNotification(id: rememberDateID, date: date)
            if isCalendarAccessEnabled {
                if let event = try? await addCalendar(rememberThisName: rememberThisName, date: date) {
                    rememberDateModel.calendarID = event.calendarItemIdentifier
                }
            }
            if isReminderAccessEnabled {
                if let event = try? await addReminder(rememberThisName: rememberThisName, date: date) {
                    rememberDateModel.reminderID = event.calendarItemIdentifier
                }
            }
            rememberDate.append(rememberDateModel)
            RememberThisSwiftDataConfiguration.context.insert(rememberDateModel)
        }
        let rememberThis = RememberScheduleModel(id: .init(), scheduleName: rememberThisName, scheduleDescription: rememberThisDescription, creationDate: Date())
        rememberThis.rememberDates = rememberDate
        RememberThisSwiftDataConfiguration.context.insert(rememberThis)
        deleteRemember()
        try? RememberThisSwiftDataConfiguration.context.save()
        self.loadRememberSchedules()
    }
    private func addNotification(id: UUID, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "기억하세요!"
        content.body = "오늘 등록한 중요한 내용을 확인하세요."
        content.sound = .default
        
        // 날짜 기반 트리거 설정
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
        
        // 알림 추가
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 오류: \(error.localizedDescription)")
            }
        }
    }
    private func addCalendar(rememberThisName: String, date: Date) async throws -> EKEvent? {
        return try await withCheckedThrowingContinuation { continuation in
            let eventStore = EKEventStore()
            // 권한 요청
            eventStore.requestFullAccessToEvents { (granted, error) in
                if granted && error == nil {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = rememberThisName
                    event.isAllDay = true
                    event.startDate = date
                    event.endDate = date
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        // 이벤트 저장
                        try eventStore.save(event, span: .thisEvent)
                        print("이벤트가 캘린더에 추가되었습니다.")
                        
                        // 성공적으로 이벤트를 저장한 후 continuation 호출
                        continuation.resume(returning: event)
                    } catch let error {
                        print("이벤트 저장 실패: \(error)")
                        continuation.resume(returning: nil)  // 저장 실패 시 nil 반환
                    }
                } else {
                    print("캘린더 접근 권한이 거부되었습니다.")
                    continuation.resume(returning: nil)  // 권한 실패 시 nil 반환
                }
            }
        }
    }
    private func addReminder(rememberThisName: String, date: Date) async throws -> EKReminder? {
        return try await withCheckedThrowingContinuation { continuation in
            let eventStore = EKEventStore()
            // 미리알림 접근 권한 요청
            eventStore.requestFullAccessToReminders { (granted, error) in
                if granted && error == nil {
                    let reminder = EKReminder(eventStore: eventStore)
                    reminder.title = rememberThisName
                    reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    reminder.calendar = eventStore.defaultCalendarForNewReminders()
                    do {
                        // 미리알림 저장
                        try eventStore.save(reminder, commit: true)
                        print("미리알림에 추가되었습니다.")
                        
                        // 성공 시 reminder 반환
                        continuation.resume(returning: reminder)
                    } catch let error {
                        print("미리알림 저장 실패: \(error)")
                        continuation.resume(returning: nil)  // 실패 시 nil 반환
                    }
                } else {
                    print("미리알림 접근 권한이 거부되었습니다.")
                    continuation.resume(returning: nil)  // 권한 실패 시 nil 반환
                }
            }
        }
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
