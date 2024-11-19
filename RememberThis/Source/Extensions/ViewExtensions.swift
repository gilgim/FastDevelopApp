//
//  ViewExtensions.swift
//  RememberThis
//
//  Created by gilgim on 9/29/24.
//
import SwiftUI
import Combine
extension View {
    func keyboardStatePublisher() -> AnyPublisher<Bool, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
        
        return Publishers.Merge(willShow, willHide)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// 키보드 상태를 확인하여 바인딩에 연결
    func observeKeyboardState(isKeyboardVisible: Binding<Bool>) -> some View {
        self.onReceive(keyboardStatePublisher()) { isVisible in
            isKeyboardVisible.wrappedValue = isVisible
        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    var topSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }
    var navigationBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .findNavigationController()?.navigationBar.frame.height ?? 0
    }
    var hostingController: UIHostingController<Self> {
        let hostingView = UIHostingController(rootView: self)
        hostingView.view.backgroundColor = .clear
        return hostingView
    }
    
    var uiView: UIView {
        return hostingController.view
    }
    
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
    func globalPosition(_ position: Binding<CGPoint>) -> some View {
        self.modifier(GlobalPositionModifier(position: position))
    }
}
