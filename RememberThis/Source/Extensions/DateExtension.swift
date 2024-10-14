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
}
