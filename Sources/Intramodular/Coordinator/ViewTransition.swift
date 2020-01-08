//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public enum ViewTransition: ViewTransitionContext {
    public enum Error: Swift.Error {
        case isRoot
        case nothingToDismiss
        case notANavigationController
    }
    
    case present(AnyView)
    case replacePresented(AnyView)
    case dismiss
    
    case push(AnyView)
    case pop
    
    case set(AnyView, navigatable: Bool = false)
    
    case none
    
    case linear([ViewTransition])
    
    case dynamic(() -> AnyPublisher<ViewTransitionContext, ViewRouterError>)
}

// MARK: - Extensions -

extension ViewTransition {
    public static func present<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.present(view.eraseToAnyView())
    }
    
    public static func replacePresented<V: View>(with view: V) -> ViewTransition {
        ViewTransition.replacePresented(view.eraseToAnyView())
    }
    
    public static func push<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.push(view.eraseToAnyView())
    }
    
    public static func set<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.set(view.eraseToAnyView(), navigatable: false)
    }
    
    public static func setNavigatable<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.set(view.eraseToAnyView(), navigatable: true)
    }
    
    public static func linear(_ transitions: ViewTransition...) -> ViewTransition {
        return .linear(transitions)
    }
}

extension ViewTransition {
    public var isNavigation: Bool {
        switch self {
            case .push, .pop:
                return true
            default:
                return false
        }
    }
    
    public var isSet: Bool {
        if case .set = self {
            return true
        } else {
            return false
        }
    }
    
    public func environmentObject<B: ObservableObject>(_ bindable: B) -> ViewTransition {
        switch self {
            case .present(let view):
                return .present(view.environmentObject(bindable))
            case .replacePresented(let view):
                return .replacePresented(with: view.environmentObject(bindable))
            case .dismiss:
                return self
            case .push(let view):
                return .push(view.environmentObject(bindable))
            case .pop:
                return self
            case .set(let view, let navigatable):
                return .set(view.environmentObject(bindable).eraseToAnyView(), navigatable: navigatable)
            case .none:
                return self
            case .linear(let transitions):
                return .linear(transitions.map({ $0.environmentObject(bindable) }))
            case .dynamic:
                return self
        }
    }
    
    public func environmentObjects(_ bindables: EnvironmentObjects) -> ViewTransition {
        switch self {
            case .present(let view):
                return .present(view.environmentObjects(bindables))
            case .replacePresented(let view):
                return .replacePresented(with: view.environmentObjects(bindables))
            case .dismiss:
                return self
            case .push(let view):
                return .push(view.environmentObjects(bindables))
            case .pop:
                return self
            case .set(let view, let navigatable):
                return .set(view.environmentObjects(bindables).eraseToAnyView(), navigatable: navigatable)
            case .none:
                return self
            case .linear(let transitions):
                return .linear(transitions.map({ $0.environmentObjects(bindables) }))
            case .dynamic:
                return self
        }
    }
    
    public func parentCoordinator<VC: ViewCoordinator>(_ coordinator: VC) -> Self {
        environmentObject(AnyViewCoordinator(coordinator))
    }
    
    func triggerPublisher<VC: ViewCoordinator>(in controller: UIViewController, animated: Bool, coordinator: VC) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        if case .dynamic(let trigger) = self {
            return trigger()
        } else if case .linear(let transitions) = self {
            if transitions.count > 1 {
                return transitions
                    .dropFirst()
                    .reduce(
                        transitions.first!.triggerPublisher(in: controller, animated: animated, coordinator: coordinator)
                    ) { publisher, transition in
                        publisher.flatMap { _ in
                            transition.triggerPublisher(in: controller, animated: animated, coordinator: coordinator)
                        }
                        .eraseToAnyPublisher()
                }
            } else if transitions.count == 1 {
                return transitions.first!.triggerPublisher(in: controller, animated: animated, coordinator: coordinator)
            } else {
                return Empty().eraseToAnyPublisher()
            }
        }
        
        return Future { attemptToFulfill in
            switch self.parentCoordinator(coordinator) {
                case .present(let view): do {
                    (controller.topMostPresentedViewController ?? controller).present(CocoaHostingController(rootView: view), animated: animated) {
                        attemptToFulfill(.success(self))
                    }
                }
                
                case .replacePresented(let view): do {
                    (controller.topMostPresentedViewController ?? controller).dismiss(animated: animated) {
                        controller.topMostPresentedViewController?.present(CocoaHostingController(rootView: view), animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    }
                }
                
                case .dismiss: do {
                    if let presentingViewController = (controller.topMostPresentedViewController ?? controller).presentingViewController {
                        presentingViewController.dismiss(animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } else {
                        attemptToFulfill(.failure(.transitionError(.nothingToDismiss)))
                    }
                }
                
                case .push(let view): do {
                    if let controller = controller as? UINavigationController {
                        controller.pushViewController(CocoaHostingController(rootView: view), animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } else {
                        attemptToFulfill(.failure(.transitionError(.notANavigationController)))
                    }
                }
                
                case .pop: do {
                    if let controller = controller as? UINavigationController {
                        controller.popViewController(animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } else {
                        attemptToFulfill(.failure(.transitionError(.notANavigationController)))
                    }
                }
                
                case .set(let view, _): do {
                    if let controller = controller as? UINavigationController {
                        controller.setViewControllers([CocoaHostingController(rootView: view)], animated: animated)
                        
                        attemptToFulfill(.success(self))
                    } else {
                        attemptToFulfill(.failure(.transitionError(.notANavigationController)))
                    }
                }
                
                case .none: do {
                    attemptToFulfill(.success(self))
                }
                
                case .linear, .dynamic:
                    fatalError()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func triggerPublisher<VC: ViewCoordinator>(in window: UIWindow, animated: Bool, coordinator: VC) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        if case .dynamic(let trigger) = self {
            return trigger()
        } else if case .linear(let transitions) = self {
            if transitions.count > 1 {
                return transitions
                    .dropFirst()
                    .reduce(
                        transitions.first!.triggerPublisher(in: window, animated: animated, coordinator: coordinator)
                    ) { publisher, transition in
                        publisher.flatMap { _ in
                            transition.triggerPublisher(in: window, animated: animated, coordinator: coordinator)
                        }
                        .eraseToAnyPublisher()
                }
            } else if transitions.count == 1 {
                return transitions.first!.triggerPublisher(in: window, animated: animated, coordinator: coordinator)
            } else {
                return Empty().eraseToAnyPublisher()
            }
        }
        
        return Future { attemptToFulfill in
            switch self.parentCoordinator(AnyViewCoordinator(coordinator)) {
                case .present(let view): do {
                    if let rootViewController = window.rootViewController {
                        (rootViewController.topMostPresentedViewController ?? rootViewController).present(CocoaHostingController(rootView: view), animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } else {
                        window.rootViewController = CocoaHostingController(rootView: view)
                        
                        attemptToFulfill(.success(self))
                    }
                }
                
                case .replacePresented(let view): do {
                    if let rootViewController = window.rootViewController {
                        (rootViewController.topMostPresentedViewController ?? rootViewController).dismiss(animated: animated) {
                            rootViewController.topMostPresentedViewController?.present(CocoaHostingController(rootView: view), animated: animated) {
                                attemptToFulfill(.success(self))
                            }
                        }
                    } else {
                        window.rootViewController = CocoaHostingController(rootView: view)
                        
                        attemptToFulfill(.success(self))
                    }
                }
                
                case .dismiss: do {
                    if let rootViewController = window.rootViewController, rootViewController.presentedViewController != nil {
                        (rootViewController.topMostPresentedViewController ?? rootViewController).dismiss(animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } else {
                        attemptToFulfill(.failure(.transitionError(.nothingToDismiss)))
                    }
                }
                
                case .push(let view): do {
                    if let rootViewController = window.rootViewController {
                        if let rootViewController = rootViewController as? UINavigationController {
                            rootViewController.pushViewController(CocoaHostingController(rootView: view), animated: animated) {
                                attemptToFulfill(.success(self))
                            }
                        } else {
                            attemptToFulfill(.failure(.transitionError(.notANavigationController)))
                        }
                    } else {
                        let rootViewController = UINavigationController()
                        
                        window.rootViewController = rootViewController
                        
                        rootViewController.pushViewController(CocoaHostingController(rootView: view), animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    }
                }
                
                case .pop: do {
                    if let rootViewController = window.rootViewController as? UINavigationController {
                        rootViewController.popViewController(animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } else {
                        attemptToFulfill(.failure(.transitionError(.notANavigationController)))
                    }
                }
                
                case .set(let view, let navigatable): do {
                    if navigatable {
                        window.rootViewController = UINavigationController(rootViewController: CocoaHostingController(rootView: view))
                    } else {
                        window.rootViewController = CocoaHostingController(rootView: view)
                    }
                }
                
                case .none: do {
                    attemptToFulfill(.success(self))
                }
                
                case .linear, .dynamic:
                    fatalError()
            }
        }
        .eraseToAnyPublisher()
    }
}
