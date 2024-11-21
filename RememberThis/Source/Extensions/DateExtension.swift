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
}
