//
//  ViewExtensions.swift
//  RememberThis
//
//  Created by gilgim on 9/29/24.
//
import SwiftUI

extension View {
    var hostingController: UIHostingController<Self> {
        UIHostingController(rootView: self)
    }
    //  단순 view만 반환
    var uiView: UIView { hostingController.view }
    
    //  하나의 hostingViewController를 참조해야한다.
    var cell: UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        let hostingController = hostingController
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        return cell
    }
}
