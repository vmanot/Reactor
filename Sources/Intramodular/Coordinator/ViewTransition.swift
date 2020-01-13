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
    
    case present(OpaqueView)
    case replacePresented(OpaqueView)
    case dismiss
    
    case push(OpaqueView)
    case pop
    
    case set(OpaqueView, navigatable: Bool = false)
    
    case none
    
    case linear([ViewTransition])
    
    case dynamic(() -> AnyPublisher<ViewTransitionContext, ViewRouterError>)
}

extension ViewTransition {
    public func transformView<V: View>(_ transform: (OpaqueView) -> V) -> ViewTransition {
        switch self {
            case .present(let view):
                return ViewTransition.present(transform(view).eraseToOpaqueView())
            case .replacePresented(let view):
                return .replacePresented(with: transform(view).eraseToOpaqueView())
            case .dismiss:
                return self
            case .push(let view):
                return ViewTransition.push(transform(view).eraseToOpaqueView())
            case .pop:
                return self
            case .set(let view, let navigatable):
                return .set(transform(view).eraseToOpaqueView(), navigatable: navigatable)
            case .none:
                return self
            case .linear(let transitions):
                return .linear(transitions.map({ $0.transformView(transform) }))
            case .dynamic:
                return self
        }
    }
}

// MARK: - Extensions -

extension ViewTransition {
    public static func present<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.present(view.eraseToOpaqueView())
    }
    
    public static func replacePresented<V: View>(with view: V) -> ViewTransition {
        ViewTransition.replacePresented(view.eraseToOpaqueView())
    }
    
    public static func push<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.push(view.eraseToOpaqueView())
    }
    
    public static func set<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.set(view.eraseToOpaqueView(), navigatable: false)
    }
    
    public static func setNavigatable<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.set(view.eraseToOpaqueView(), navigatable: true)
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
        transformView {
            $0.environmentObject(bindable).name($0.name)
        }
    }
    
    public func environmentObjects(_ bindables: EnvironmentObjects) -> ViewTransition {
        transformView {
            $0.environmentObjects(bindables).name($0.name)
        }
    }
    
    public func parentCoordinator<VC: ViewCoordinator>(_ coordinator: VC) -> Self {
        environmentObject(AnyViewCoordinator(coordinator))
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ViewTransition {
    func triggerPublisher<VC: ViewCoordinator>(in controller: UIViewController, animated: Bool, coordinator: VC) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        if case .dynamic(let trigger) = self {
            return trigger()
        }
        
        let transition = self.parentCoordinator(AnyViewCoordinator(coordinator))
        
        return Future { attemptToFulfill in
            do {
                try controller.trigger(transition, animated: animated) {
                    attemptToFulfill(.success(transition))
                }
            } catch {
                attemptToFulfill(.failure(.init(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func triggerPublisher<VC: ViewCoordinator>(in window: UIWindow, animated: Bool, coordinator: VC) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let transition = parentCoordinator(AnyViewCoordinator(coordinator))
        
        if case .dynamic(let trigger) = self {
            return trigger()
        }
        
        return Future { attemptToFulfill in
            switch transition {
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
                
                default: do {
                    do {
                        try window.rootViewController!
                            .trigger(self.parentCoordinator(AnyViewCoordinator(coordinator)), animated: animated) {
                                attemptToFulfill(.success(self))
                        }
                    } catch {
                        attemptToFulfill(.failure(.init(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
