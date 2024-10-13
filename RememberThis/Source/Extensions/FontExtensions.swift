//
//  FontExtensions.swift
//  RememberThis
//
//  Created by gilgim on 9/29/24.
//

import SwiftUI

extension Font {
    static func tenada(size: CGFloat) -> Font {
        return Font.custom("Tenada", size: size)
    }
    static func pretendard(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom("Pretendard-\(fontWeightName(for: weight))", size: size)
    }
    private static func fontWeightName(for weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight: return "Thin"
        case .thin: return "ExtraLight"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "SemiBold"
        case .bold: return "Bold"
        case .heavy: return "ExtraBold"
        case .black: return "Black"
        default: return "Regular"  // 기본값
        }
    }
}
