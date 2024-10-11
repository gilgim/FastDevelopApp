//
//  RememberThisSplashViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/11/24.
//

import Foundation
import EventKit
import UserNotifications

@Observable
class RememberThisSplashViewModel {
    let eventStore = EKEventStore()
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한이 승인되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
        eventStore.requestFullAccessToEvents { granted, error in
            if granted {
                print("캘린더에 대한 전체 접근 권한이 허가되었습니다.")
            } else {
                print("캘린더 접근 권한이 거부되었습니다.")
            }
        }
        eventStore.requestFullAccessToReminders { granted, error in
            if granted {
                print("미리알림에 대한 전체 접근 권한이 허가되었습니다.")
            } else {
                print("미리알림 접근 권한이 거부되었습니다.")
            }
        }
    }
}
