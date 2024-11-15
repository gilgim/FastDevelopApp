//
//  GlobalPositionModifier.swift
//  RememberThis
//
//  Created by gaea on 11/14/24.
//

import Foundation
import SwiftUI

struct GlobalPositionModifier: ViewModifier {
    @Binding var position: CGPoint
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global)) { _, newValue in
                            position = newValue.origin
                        }
                }
            )
    }
}
