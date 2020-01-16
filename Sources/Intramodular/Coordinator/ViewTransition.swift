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
    
    case present(AnyPresentationView)
    case replacePresented(AnyPresentationView)
    case dismiss
    
    case push(AnyPresentationView)
    case pop
    
    case set(AnyPresentationView)
    
    case none
    
    case linear([ViewTransition])
    
    case dynamic(() -> AnyPublisher<ViewTransitionContext, ViewRouterError>)
}

extension ViewTransition {
    public func transformView<V: View>(_ transform: (AnyPresentationView) -> V) -> ViewTransition {
        switch self {
            case .present(let view):
                return ViewTransition.present(transform(view).eraseToAnyPresentationView())
            case .replacePresented(let view):
                return ViewTransition.replacePresented(with: transform(view).eraseToAnyPresentationView())
            case .dismiss:
                return self
            case .push(let view):
                return ViewTransition.push(transform(view).eraseToAnyPresentationView())
            case .pop:
                return self
            case .set(let view):
                return ViewTransition.set(transform(view).eraseToAnyPresentationView())
            case .none:
                return self
            case .linear(let transitions):
                return ViewTransition.linear(transitions.map({ $0.transformView(transform) }))
            case .dynamic:
                return self
        }
    }
}

// MARK: - Extensions -

extension ViewTransition {
    public static func present<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.present(view.eraseToAnyPresentationView())
    }
    
    public static func replacePresented<V: View>(with view: V) -> ViewTransition {
        ViewTransition.replacePresented(view.eraseToAnyPresentationView())
    }
    
    public static func push<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.push(view.eraseToAnyPresentationView())
    }
    
    public static func set<V: View>(_ view: V) -> ViewTransition {
        ViewTransition.set(view.eraseToAnyPresentationView())
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
                case .set(let view): do {
                    window.rootViewController = CocoaHostingController(rootView: view)
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
