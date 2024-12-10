//
//  RemeberTensorFlowWeightModel.swift
//  RememberThis
//
//  Created by gaea on 12/10/24.
//

import Foundation
import SwiftData

@Model
class RemeberTensorFlowWeightModel {
    var weight: Data
    init(weight: Data) {
        self.weight = weight
    }
}
