//
//  ListViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation
import EventKit
import UserNotifications

@Observable
class ListViewModel {
    var remembers: [RememberModel] = []
    
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
            RememberThisConfiguration.context.delete(rememberDate)
        }
        RememberThisConfiguration.context.delete(rememberThis)  // 데이터 삭제
        try? RememberThisConfiguration.context.save()  // 변경 사항 저장
        
    }
}
