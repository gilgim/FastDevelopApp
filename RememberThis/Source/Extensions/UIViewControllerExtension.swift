//
//  UIViewControllerExtension.swift
//  RememberThis
//
//  Created by gaea on 11/15/24.
//
import UIKit

extension UIViewController {
    func findNavigationController() -> UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }
        for child in children {
            if let navController = child.findNavigationController() {
                return navController
            }
        }
        return nil
    }
}
