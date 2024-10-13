//
//  RememberThisListViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation
import EventKit
import UserNotifications

@Observable
class RememberThisListViewModel {
    @MainActor
    func deleteRemember(_ rememberThis: RememberModel) {
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
    }
    //  생성날짜
    func createDateText(_ rememberDate: RememberModel) -> String {
        let date = rememberDate.createDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 부터"
        return formatter.string(from: date)
    }
    //  완료날짜
    //  지난기간
    //  실제일정
    func rememberDateText(_ rememberDate: RememberDateModel) -> String {
        let date = rememberDate.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    enum ReminderStatus {
        case incomplete      // 미완료
        case complete        // 완료
        case urgent          // 빠름 (긴급)
        case overdue         // 일정 지남 (기한 초과)
    }
    
    @MainActor
    func rememberDateOk(_ rememberDate: RememberDateModel) {
        let rememberDate = RememberThisSwiftDataConfiguration.loadData(RememberDateModel.self)?.filter({$0.id == rememberDate.id})
        if let rememberDate {
            
        }
        try? RememberThisSwiftDataConfiguration.context.save()
    }
    
    func rememberDateCheck(_ rememberDate: RememberDateModel) -> ReminderStatus {
        let eventStore = EKEventStore()
        
        // EventKit의 reminderID가 있을 경우
        if let reminderID = rememberDate.reminderID,
           let reminder = eventStore.calendarItem(withIdentifier: reminderID) as? EKReminder {
            
            // 미리 알림이 완료된 경우
            if let completionDate = reminder.completionDate {
                return completionDate < Date() ? .urgent : .complete
            }
            
            // 미리 알림이 완료되지 않았고, 기한이 지난 경우
            return rememberDate.date < Date() ? .overdue : .incomplete
        }
        
        // EventKit의 reminderID가 없을 경우
        if let completeDate = rememberDate.completeDate {
            return completeDate < Date() ? .urgent : .complete
        }
        
        // 미리 알림이 완료되지 않았고, 기한이 지난 경우
        return rememberDate.date < Date() ? .overdue : .incomplete
    }
}
