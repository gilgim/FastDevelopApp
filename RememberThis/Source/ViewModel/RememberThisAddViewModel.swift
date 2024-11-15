//
//  RememberThisAddViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation
import EventKit
import UserNotifications

@Observable
class RememberThisAddViewModel {
    var rememberThisName: String = ""
    var rememberThisDescription: String = ""
    var rememberRepeatDates: [Date] {
        get {
            return _rememberRepeatDates
        }
        set {
            let differences = zip(_rememberRepeatDates, newValue).enumerated().compactMap { index, pair -> (index: Int, old: Date, new: Date)? in
                if pair.0 != pair.1 {
                    return (index: index, old: pair.0, new: pair.1)
                }
                return nil
            }
            
            if !differences.isEmpty {
                for difference in differences {
                    print("변경된 인덱스: \(difference.index), 이전 값: \(difference.old), 새 값: \(difference.new)")
                    
                    // 0번째 인덱스가 변경되었을 경우
                    if difference.index == 0 {
                        let newFirstDate = difference.new
                        
                        // 기존 간격 계산
                        var intervals: [Int] = []
                        for i in 1..<_rememberRepeatDates.count {
                            let interval = Calendar.current.dateComponents([.day], from: _rememberRepeatDates[i - 1], to: _rememberRepeatDates[i]).day ?? 0
                            intervals.append(interval)
                        }
                        
                        // 새 간격 적용
                        _rememberRepeatDates[0] = newFirstDate
                        for i in 1..<_rememberRepeatDates.count {
                            if let adjustedDate = Calendar.current.date(byAdding: .day, value: intervals[i - 1], to: _rememberRepeatDates[i - 1]) {
                                _rememberRepeatDates[i] = adjustedDate
                            }
                        }
                        
                        print("간격 유지 후 새로운 날짜 배열: \(_rememberRepeatDates)")
                    }
                }
            }
            
            // 값 업데이트
            _rememberRepeatDates = newValue
        }
    }
    var _rememberRepeatDates: [Date] = [Date()]
    var isCalendarAccessEnabled: Bool = false
    var isReminderAccessEnabled: Bool = false
    
    func dateFormatterString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter.string(from: date)
    }
    
    func sortDate() {
        rememberRepeatDates.sort()
    }
    func addDate() {
        if let lastDate = rememberRepeatDates.last {
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!
            rememberRepeatDates.append(nextDate)
        }
    }
    @MainActor
    func createRemember() async {
        //  스위프트 데이터에 추가
        var rememberDate: [RememberScheduleDetailModel] = []
        for date in rememberRepeatDates {
            let rememberDateID = UUID()
            let rememberDateModel = RememberScheduleDetailModel(id: rememberDateID, date: date)
            self.addNotification(id: rememberDateID, date: date)
            if isCalendarAccessEnabled {
                if let event = try? await addCalendar(date: date) {
                    rememberDateModel.calendarID = event.calendarItemIdentifier
                }
            }
            if isReminderAccessEnabled {
                if let event = try? await addReminder(date: date) {
                    rememberDateModel.reminderID = event.calendarItemIdentifier
                }
            }
            rememberDate.append(rememberDateModel)
            RememberThisSwiftDataConfiguration.context.insert(rememberDateModel)
        }
        let rememberThis = RememberScheduleModel(id: .init(), scheduleName: rememberThisName, scheduleDescription: rememberThisDescription, creationDate: Date())
        rememberThis.rememberDates = rememberDate
        RememberThisSwiftDataConfiguration.context.insert(rememberThis)
        try? RememberThisSwiftDataConfiguration.context.save()
    }
    func addNotification(id: UUID, date: Date) {
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
    func addCalendar(date: Date) async throws -> EKEvent? {
        return try await withCheckedThrowingContinuation { continuation in
            let eventStore = EKEventStore()
            // 권한 요청
            eventStore.requestFullAccessToEvents { (granted, error) in
                if granted && error == nil {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = self.rememberThisName
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
    func addReminder(date: Date) async throws -> EKReminder? {
        return try await withCheckedThrowingContinuation { continuation in
            let eventStore = EKEventStore()
            // 미리알림 접근 권한 요청
            eventStore.requestFullAccessToReminders { (granted, error) in
                if granted && error == nil {
                    let reminder = EKReminder(eventStore: eventStore)
                    reminder.title = self.rememberThisName
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
    func rememberRepeatCycle(targetIndex: Int) -> String {
        let firstDate = self.rememberRepeatDates.first ?? Date()
        let targetDate = self.rememberRepeatDates[targetIndex]
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: firstDate, to: targetDate)
        
        var result = ""
        
        if let years = components.year, years > 0 {
            result += "\(years)년 "
        }
        
        if let months = components.month, months > 0 {
            result += "\(months)달 "
        }
        
        if let days = components.day, days > 0 {
            result += "\(days)일 "
        }
        
        if let hours = components.hour, hours > 0 {
            result += "\(hours)시간 "
        }
        
        if let minutes = components.minute, minutes > 0 {
            result += "\(minutes)분 "
        }
        
        return result.isEmpty ? "0분" : result.trimmingCharacters(in: .whitespaces)
    }
    func dateRange(for index: Int) -> ClosedRange<Date>? {
        guard rememberRepeatDates.indices.contains(index) else { return nil }
        
        let previousDate = index > 0 ? rememberRepeatDates[index - 1] : nil
        let nextDate = index < rememberRepeatDates.count - 1 ? rememberRepeatDates[index + 1] : nil
        
        if let previousDate = previousDate, let nextDate = nextDate {
            return previousDate...nextDate
        } else if let previousDate = previousDate {
            return previousDate...Date.distantFuture
        } else if let nextDate = nextDate {
            return Date.distantPast...nextDate
        }
        return nil
    }
    func updateDates(afterChangingFirstDateTo newDate: Date) {
        guard !rememberRepeatDates.isEmpty else { return }
        
        // 첫 번째 날짜 업데이트
        rememberRepeatDates[0] = newDate
        
        // 기존 날짜 간격 유지
        for i in 1..<rememberRepeatDates.count {
            let interval = Calendar.current.dateComponents([.day], from: rememberRepeatDates[i - 1], to: rememberRepeatDates[i])
            if let days = interval.day {
                rememberRepeatDates[i] = Calendar.current.date(byAdding: .day, value: days, to: rememberRepeatDates[i - 1])!
            }
        }
    }
}
