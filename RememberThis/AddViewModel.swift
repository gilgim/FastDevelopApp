//
//  AddViewModel.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//
import Foundation

@Observable
class AddViewModel {
    var rememberThisName: String = ""
    var rememberRepeatDates: [Date] = []
    func dateFormatterString(date: Date) -> String {
        var formatter = DateFormatter()
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
        } else {
            rememberRepeatDates.append(Date())
        }
    }
    @MainActor func saveRememberThis() {
        for rememberRepeatDate in rememberRepeatDates {
            
        }
        try? RememberThisConfiguration.context.save()
    }
}
