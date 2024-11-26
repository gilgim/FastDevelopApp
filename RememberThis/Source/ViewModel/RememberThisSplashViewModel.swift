//
//  RememberThisSplashViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/11/24.
//

import Foundation
import EventKit
import UserNotifications
import UIKit

@Observable
class RememberThisSplashViewModel {
    var updateView: Bool = false
    var isAccessToEvents: Bool { EKEventStore.authorizationStatus(for: .event) == .authorized }
    var isAccessToReminders: Bool { EKEventStore.authorizationStatus(for: .reminder) == .authorized }
    
    private let eventStore = EKEventStore()
    private var age: Int = 3
    private var memoryLevel: Int = 3
    
    func isSelectAge(value: Int) -> Bool {
        return age == value
    }
    func isSelectMemoryLevel(value: Int) -> Bool {
        return memoryLevel == value
    }
    func selectAge(value: Int) {
        self.age = value
    }
    func selectMemoryLevel(value: Int) {
        self.memoryLevel = value
    }
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
                self.updateView.toggle()
            } else {
                print("캘린더 접근 권한이 거부되었습니다.")
            }
        }
        eventStore.requestFullAccessToReminders { granted, error in
            if granted {
                self.updateView.toggle()
            } else {
                print("미리알림 접근 권한이 거부되었습니다.")
            }
        }
    }
    func moveSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    @MainActor
    func saveUserData() {
        let userModel = RememberUserModel(id: .init(), age: self.age, memoryLevel: self.memoryLevel)
        RememberThisSwiftDataConfiguration.context.insert(userModel)
        try? RememberThisSwiftDataConfiguration.context.save()
    }
}
