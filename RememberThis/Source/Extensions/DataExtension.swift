//
//  DataExtension.swift
//  RememberThis
//
//  Created by gaea on 12/10/24.
//
import Foundation

extension Data {
    func toArray<T>(type: T.Type) -> [T] {
        return withUnsafeBytes { pointer in
            Array(pointer.bindMemory(to: T.self))
        }
    }
}
