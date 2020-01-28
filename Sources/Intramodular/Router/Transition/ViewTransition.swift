//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public struct ViewTransition: ViewTransitionContext {
    public enum Error: Swift.Error {
        case isRoot
        case nothingToDismiss
        case notANavigationController
    }
    
    private var _payload: Payload
    private var _environment: EnvironmentBuilder

    var payload: Payload {
        _payload.transformView({ $0 = $0.mergeEnvironmentBuilder(_environment) })
    }
}

extension ViewTransition {
    var _payloadView: AnyPresentationView? {
        switch _payload {
            case .present(let view):
                return view
            case .replacePresented(let view):
                return view
            case .dismiss:
                return nil
            case .dismissView:
                return nil
            case .push(let view):
                return view
            case .pop:
                return nil
            case .set(let view):
                return view
            case .linear:
                return nil
            case .dynamic:
                return nil
        }
    }
        
    func transformView(_ transform: (inout AnyPresentationView) -> Void) -> Self {
        var result = self
        
        result._payload = _payload.transformView(transform)
        
        return result
    }
    
    init(_ _payload: ViewTransition.Payload) {
        self._payload = _payload
        self._environment = .init()
    }
}

// MARK: - API -

extension ViewTransition {
    public static func present<V: View>(_ view: V) -> ViewTransition {
        .init(.present(.init(view)))
    }
    
    public static func replacePresented<V: View>(with view: V) -> ViewTransition {
        .init(.replacePresented(with: .init(view)))
    }
    
    public static var dismiss: ViewTransition {
        .init(.dismiss)
    }
    
    public static func dismissView<H: Hashable>(named name: H) -> ViewTransition {
        .init(.dismissView(named: .init(name)))
    }
    
    public static func push<V: View>(_ view: V) -> ViewTransition {
        .init(.push(.init(view)))
    }
    
    public static var pop: ViewTransition {
        .init(.pop)
    }
    
    public static func set<V: View>(_ view: V) -> ViewTransition {
        .init(.set(.init(view)))
    }
    
    public static func linear(_ transitions: [ViewTransition]) -> ViewTransition {
        .init(.linear(transitions))
    }
    
    public static func linear(_ transitions: ViewTransition...) -> ViewTransition {
        linear(transitions)
    }
    
    public static func dynamic(
        _ body: @escaping () -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    ) -> ViewTransition {
        .init(.dynamic(body))
    }
}

extension ViewTransition {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> ViewTransition {
        var result = self
        
        result._environment.merge(builder)
        
        return result
    }
    
    public func mergeCoordinator<VC: ViewCoordinator>(_ coordinator: VC) -> Self {
        mergeEnvironmentBuilder(.object(coordinator))
            .mergeEnvironmentBuilder(.object(AnyViewCoordinator(coordinator)))
    }
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ViewTransition {
    func triggerPublisher<VC: ViewCoordinator>(in controller: UIViewController, animated: Bool, coordinator: VC) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let transition = mergeCoordinator(coordinator)
        
        if case .dynamic(let trigger) = transition.payload {
            return trigger()
        }
        
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
        let transition = mergeCoordinator(coordinator)
        
        if case .dynamic(let trigger) = transition.payload {
            return trigger()
        }
        
        return Future { attemptToFulfill in
            switch transition.payload {
                case .set(let view): do {
                    window.rootViewController = CocoaHostingController(rootView: view)
                }
                
                default: do {
                    do {
                        try window.rootViewController!.trigger(transition, animated: animated) {
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
