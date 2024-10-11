//
//  ColorExtension.swift
//  RememberThis
//
//  Created by gaea on 10/11/24.
//

import SwiftUI

extension Color {
    static let black87 = Color.black.opacity(0.87)
    static let black58 = Color.black.opacity(0.58)
    static let black38 = Color.black.opacity(0.38)
    static let black12 = Color.black.opacity(0.12)
    static let customSilver = Color(hex: "#E3E3E3")
    static let etherealBlue = Color(hex: "#A3DFFF")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
