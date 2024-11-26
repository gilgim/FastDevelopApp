//
//  DateExtension.swift
//  RememberThis
//
//  Created by gaea on 10/14/24.
//

import Foundation

extension Date {
    func formmatToString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    /// Compares two dates at the day level.
    func isBeforeDay(_ otherDate: Date) -> Bool {
        let calendar = Calendar.current
        guard let selfDay = calendar.ordinality(of: .day, in: .era, for: self),
              let otherDay = calendar.ordinality(of: .day, in: .era, for: otherDate) else {
            return false
        }
        return selfDay < otherDay
    }
    
    func isAfterDay(_ otherDate: Date) -> Bool {
        let calendar = Calendar.current
        guard let selfDay = calendar.ordinality(of: .day, in: .era, for: self),
              let otherDay = calendar.ordinality(of: .day, in: .era, for: otherDate) else {
            return false
        }
        return selfDay > otherDay
    }
    
    func differenceInDays(to otherDate: Date) -> Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfOther = calendar.startOfDay(for: otherDate)
        
        guard let daysDifference = calendar.dateComponents([.day], from: startOfSelf, to: startOfOther).day else {
            return 0
        }
        return daysDifference
    }
    
    func addingDays(_ days: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: days, to: self) ?? self
    }
}
