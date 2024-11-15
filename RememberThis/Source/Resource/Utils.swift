//
//  Utils.swift
//  RememberThis
//
//  Created by gaea on 11/14/24.
//
import UIKit

func getTopMostViewController() -> UIViewController? {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
        return getTopViewController(rootViewController)
    }
    return nil
}

private func getTopViewController(_ rootViewController: UIViewController) -> UIViewController {
    if let presentedViewController = rootViewController.presentedViewController {
        return getTopViewController(presentedViewController)
    } else if let navigationController = rootViewController as? UINavigationController,
              let visibleViewController = navigationController.visibleViewController {
        return getTopViewController(visibleViewController)
    } else if let tabBarController = rootViewController as? UITabBarController,
              let selectedViewController = tabBarController.selectedViewController {
        return getTopViewController(selectedViewController)
    } else {
        return rootViewController
    }
}

func addViewToTopMostView(_ viewToAdd: UIView) {
    DispatchQueue.main.async {
        if let topViewController = getTopMostViewController() {
            viewToAdd.frame = topViewController.view.bounds
            topViewController.view.addSubview(viewToAdd)
        }
    }
}
