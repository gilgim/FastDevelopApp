//
//  RememberThisAddViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation
import EventKit
import UserNotifications
import Combine
import TensorFlowLite

@Observable
class RememberThisAddViewModel {
    var rememberThisName: String = ""
    var rememberThisDescription: String = ""
    var rememberRepeatDates: [Date] {
        get {
            return _rememberRepeatDates
        }
        set {
            self.rememberRepeatDatesEvent.send(newValue)
        }
    }
    var _rememberRepeatDates: [Date] = [Date()]
    var isCalendarAccessEnabled: Bool = false
    var isReminderAccessEnabled: Bool = false
   
    private var rememberRepeatDatesEvent: PassthroughSubject<[Date], Never> = .init()
    var cancellable = Set<AnyCancellable>()
    
    init() {
        rememberRepeatDatesEvent.sink { dates in
            self._rememberRepeatDates = self.updateRememberRepeatDates(newDates: dates)
        }.store(in: &cancellable)
    }
    private func updateRememberRepeatDates(newDates: [Date]) -> [Date] {
        var returnDate = newDates
        if _rememberRepeatDates[0] != newDates[0] {
            var dayInterval: [Int] = []
            let calendar = Calendar.current
            for index in 1..<_rememberRepeatDates.count {
                let component = calendar.dateComponents([.day], from: _rememberRepeatDates[0], to: _rememberRepeatDates[index])
                if let day = component.day {
                    dayInterval.append(day)
                }
            }
            for index in 1..<returnDate.count {
                if let editDay = calendar.date(byAdding: .day, value: dayInterval[index-1], to: returnDate[0]) {
                    returnDate[index] = editDay
                }
            }
            return returnDate
        } else {
            returnDate.sort{$0 < $1}
            return returnDate
        }
    }
    func dateIntervals() -> [Int] {
        var dayInterval: [Int] = []
        var targetDate = _rememberRepeatDates[0]
        let calendar = Calendar.current
        for index in 1..<_rememberRepeatDates.count {
            let component = calendar.dateComponents([.day], from: targetDate, to: _rememberRepeatDates[index])
            if let day = component.day {
                dayInterval.append(day)
            }
            targetDate = _rememberRepeatDates[index]
        }
        return dayInterval
    }
    func dateIntervalsLastTarget() -> Int {
        let targetDate = _rememberRepeatDates[0]
        let calendar = Calendar.current
        let component = calendar.dateComponents([.day], from: targetDate, to: _rememberRepeatDates[_rememberRepeatDates.count-1])
        if let day = component.day {
            return day
        } else {
            return 0
        }
    }
    func dateIntervalsFirstTarget() -> [Int] {
        var dayInterval: [Int] = []
        let targetDate = _rememberRepeatDates[0]
        let calendar = Calendar.current
        for index in 1..<_rememberRepeatDates.count {
            let component = calendar.dateComponents([.day], from: targetDate, to: _rememberRepeatDates[index])
            if let day = component.day {
                dayInterval.append(day)
            }
        }
        return dayInterval
    }
    func dateFormatterString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter.string(from: date)
    }
    
    func sortDate() {
        rememberRepeatDates.sort()
    }
    @MainActor
    func addDate() {
        guard let userDatas = RememberThisSwiftDataConfiguration.loadData(RememberUserModel.self),
              let userData = userDatas.first else { return }
        let R = 0.5 // 기준 기억률
        var k0 = 0.7
        let repeatCount = Double(rememberRepeatDates.count)
        let repeatEffect = 1 * 0.75
        
        // 사용자 데이터 (5~1 점수 정규화)
        let memoryLevelNormalized = Double(userData.memoryLevel) / 5.0
        let ageNormalized = Double(userData.age) / 5.0
        let ageWeight = self.ageWeight(age: userData.age)
        let memoryWeight = 1 - ageWeight
        let userEffect = (memoryWeight * memoryLevelNormalized) + (ageWeight * (1 - ageNormalized))
        let dataCount = RememberThisSwiftDataConfiguration.loadData(RememberScheduleDetailModel.self)
        //  한달 치 데이터
        if dataCount?.count ?? 0 > 31 {
            let tensorFlowLiteManager = TensorFlowLiteManager()
            tensorFlowLiteManager.loadModel()
            k0 = Double(tensorFlowLiteManager.predictKValue(inputData: [Float32(repeatCount), Float32(memoryLevelNormalized), Float32(ageNormalized), Float32(repeatEffect)]) ?? 0)
        }
        let k = k0 / (1 + log(1 + repeatCount) + repeatEffect + userEffect)
        
        // 기억률이 R에 도달하는 시간 계산
        let t = -log(R) / k // t = -ln(R) / k
        let day = max(1, Int(t.rounded())) // 최소 1일 보장
        
        // 다음 날짜 추가
        if let lastDate = rememberRepeatDates.last {
            let nextDate = Calendar.current.date(byAdding: .day, value: day, to: lastDate)!
            rememberRepeatDates.append(nextDate)
        } else {
            // 비어 있는 경우 현재 날짜부터 시작
            let nextDate = Calendar.current.date(byAdding: .day, value: day, to: Date())!
            rememberRepeatDates.append(nextDate)
        }
    }
    @MainActor
    func isReviewCompleted() -> Bool {
        guard let userDatas = RememberThisSwiftDataConfiguration.loadData(RememberUserModel.self),
              let userData = userDatas.first else { return false }
        let k0 = 0.7
        let repeatCount = max(1, Double(rememberRepeatDates.count))
        let repeatEffect = 1 * 0.75

        let memoryLevelNormalized = Double(userData.memoryLevel) / 5.0
        let ageNormalized = Double(userData.age) / 5.0
        let ageWeight = self.ageWeight(age: userData.age)
        let memoryWeight = 1 - ageWeight

        let userEffect = (memoryWeight * memoryLevelNormalized) + (ageWeight * (1 - ageNormalized))
        
        // 보정된 k 값 계산
        let k = k0 / (1 + log(1 + repeatCount) + repeatEffect + userEffect)
        
        // 현재 기억률 계산 및 0.5 수렴 여부 확인
        return doesConvergeToHalf(k: k)
    }
    func doesConvergeToHalf(k: Double, threshold: Double = 1e-6, maxIterations: Int = 1000) -> Bool {
        var x: Double = 1.0 // 초기 x 값
        var previousValue: Double = exp(-k * x)
        var iterationCount = 0 // 반복 횟수 추적

        while iterationCount < maxIterations {
            x += 1.0 // x를 점차 증가
            let currentValue = exp(-k * x)
            
            // 수렴값이 0.5에 가까운지 확인
            if abs(currentValue - 0.5) < threshold {
                return true // 0.5로 수렴
            }
            
            // 변화가 매우 작아지면 반복 종료
            if abs(currentValue - previousValue) < threshold {
                break
            }
            
            previousValue = currentValue
            iterationCount += 1
        }
        return false // 0.5로 수렴하지 않음
    }
    func ageWeight(age: Int) -> Double {
        switch age {
        case 5: // 10대
            return 0.2
        case 4: // 20대
            return 0.3
        case 3: // 30대
            return 0.4
        case 2: // 40대
            return 0.5
        case 1: // 50대
            return 0.6
        default:
            return 0.4
        }
    }
    func rememberIntervalEquation(n: Double, t: Double) -> Double {
        let k0 = 0.7
        let repeatCount = n * 1
        let repeatEffect = 1 * 0.75
        let userEffect = 1 * 0.75
        let k = k0 / (1 + repeatCount + repeatEffect + userEffect)
        return exp(-k * t)
    }
    func removeDate(_ index: Int) {
        self._rememberRepeatDates.remove(at: index)
        self._rememberRepeatDates.sort{$0 < $1}
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
    func dateRange(for date: Date) -> Any? {
        if let selectIndex = _rememberRepeatDates.firstIndex(of: date), selectIndex > 0 && selectIndex < _rememberRepeatDates.count - 1 {
            // 중간에 위치한 날짜 처리
            if let startDate = Calendar.current.date(byAdding: .day, value: 1, to: _rememberRepeatDates[selectIndex - 1]),
               let endDate = Calendar.current.date(byAdding: .day, value: -1, to: _rememberRepeatDates[selectIndex + 1]) {
                return startDate...endDate
            } else {
                return nil
            }
        } else if let selectIndex = _rememberRepeatDates.firstIndex(of: date), selectIndex > 0 && selectIndex >= _rememberRepeatDates.count - 1 {
            // 마지막 날짜 처리
            if let startDate = Calendar.current.date(byAdding: .day, value: 1, to: _rememberRepeatDates[selectIndex - 1]) {
                return startDate...
            } else {
                return nil
            }
        } else if let selectIndex = _rememberRepeatDates.firstIndex(of: date), selectIndex == 0 {
            // 첫 번째 날짜 처리
            if let endDate = Calendar.current.date(byAdding: .year, value: 1000, to: Date()) {
                return ...endDate
            } else {
                return nil
            }
        } else {
            return nil
        }
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
