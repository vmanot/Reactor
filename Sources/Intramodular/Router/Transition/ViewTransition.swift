//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public struct ViewTransition {
    public enum Error: Swift.Error {
        case cannotPopRoot
        case isRoot
        case nothingToDismiss
        case navigationControllerMissing
        case cannotSetRoot
    }
    
    private var _payload: Payload
    
    private var _payloadView: EnvironmentalAnyView? {
        get {
            _payload.view
        } set {
            _payload.view = newValue
        }
    }
    
    @usableFromInline
    var payload: Payload {
        var result = _payload
        
        result.mutateViewInPlace({
            $0.mergeEnvironmentBuilderInPlace(environmentBuilder)
        })
        
        return result
    }
    
    @usableFromInline
    var animated: Bool = true
    
    @usableFromInline
    var payloadViewName: ViewName?
    
    @usableFromInline
    var payloadViewType: Any.Type
    
    @usableFromInline
    var environmentBuilder: EnvironmentBuilder
    
    @usableFromInline
    init<V: View>(payload: ViewTransition.Payload, view: V) {
        self._payload = payload
        self.payloadViewName = (view as? opaque_NamedView)?.name
        self.payloadViewType = type(of: view)
        self.environmentBuilder = .init()
    }
    
    @usableFromInline
    init(payload: ViewTransition.Payload) {
        self.init(payload: payload, view: EmptyView())
    }
}

// MARK: - Protocol Implementations -

extension ViewTransition: ViewTransitionContext {
    @inlinable
    public var view: EnvironmentalAnyView? {
        payload.view
    }
}

// MARK: - API -

extension ViewTransition {
    @inlinable
    public static func present<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .present(.init(view)), view: view)
    }
    
    @inlinable
    public static func replacePresented<V: View>(with view: V) -> ViewTransition {
        .init(payload: .replacePresented(with: .init(view)), view: view)
    }
    
    @inlinable
    public static var dismiss: ViewTransition {
        .init(payload: .dismiss)
    }
    
    @inlinable
    public static func dismissView<H: Hashable>(named name: H) -> ViewTransition {
        .init(payload: .dismissView(named: .init(name)))
    }
    
    @inlinable
    public static func push<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .push(.init(view)), view: view)
    }
    
    @inlinable
    public static func pushOrPresent<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .pushOrPresent(.init(view)), view: view)
    }
    
    @inlinable
    public static var pop: ViewTransition {
        .init(payload: .pop)
    }
    
    @inlinable
    public static var popToRoot: ViewTransition {
        .init(payload: .popToRoot)
    }
    
    @inlinable
    public static var popOrDismiss: ViewTransition {
        .init(payload: .popOrDismiss)
    }
    
    @inlinable
    public static func set<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .set(.init(view)), view: view)
    }
    
    @inlinable
    public static func setRoot<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .setRoot(.init(view)), view: view)
    }
    
    @inlinable
    public static func setNavigatable<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .setNavigatable(.init(view)), view: view)
    }
    
    @inlinable
    public static func linear(_ transitions: [ViewTransition]) -> ViewTransition {
        .init(payload: .linear(transitions))
    }
    
    @inlinable
    public static func linear(_ transitions: ViewTransition...) -> ViewTransition {
        linear(transitions)
    }
    
    @inlinable
    public static func dynamic(
        _ body: @escaping () -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    ) -> ViewTransition {
        .init(payload: .dynamic(body))
    }
    
    @inlinable
    public static var none: ViewTransition {
        .init(payload: .none)
    }
}

extension ViewTransition {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> ViewTransition {
        var result = self
        
        result.environmentBuilder.merge(builder)
        
        return result
    }
    
    public func mergeCoordinator<VC: ViewCoordinator>(_ coordinator: VC) -> Self {
        mergeEnvironmentBuilder(.object(coordinator))
            .mergeEnvironmentBuilder(.object(AnyViewCoordinator(coordinator)))
    }
}

// MARK: - Helpers -

extension ViewTransition.Payload {
    mutating func mutateViewInPlace(_ body: (inout EnvironmentalAnyView) -> Void) {
        switch self {
            case .linear(let transitions):
                self = .linear(transitions.map({
                    var transition = $0
                    
                    transition.mutateViewInPlace(body)
                    
                    return transition
                }))
            default: do {
                if var view = self.view {
                    body(&view)
                    
                    self.view = view
                }
            }
        }
    }
}

extension ViewTransition {
    mutating func mutateViewInPlace(_ body: (inout EnvironmentalAnyView) -> Void) {
        switch _payload {
            case .linear(let transitions):
                _payload = .linear(transitions.map({
                    var transition = $0
                    
                    transition.mutateViewInPlace(body)
                    
                    return transition
                }))
            default: do {
                if var view = payload.view {
                    body(&view)
                    
                    _payload.view = view
                }
            }
        }
    }
}
