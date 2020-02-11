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
        case navigationControllerMissing
    }
    
    private var _payload: Payload
    
    var payload: Payload {
        _payload.transformViewIfPresent({ $0 = $0.mergeEnvironmentBuilder(environmentBuilder) })
    }
    
    var animated: Bool = true
    var payloadViewName: ViewName?
    var environmentBuilder: EnvironmentBuilder
    
    init<V: View>(payload: ViewTransition.Payload, view: V) {
        self._payload = payload
        self.payloadViewName = (view as? opaque_NamedView)?.name
        self.environmentBuilder = .init()
    }
    
    init(payload: ViewTransition.Payload) {
        self.init(payload: payload, view: EmptyView())
    }
    
    func transformViewIfPresent(_ transform: (inout EnvironmentalAnyView) -> Void) -> Self {
        var result = self
        
        result._payload = _payload.transformViewIfPresent(transform)
        
        return result
    }
}

// MARK: - API -

extension ViewTransition {
    public static func present<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .present(.init(view)), view: view)
    }
    
    public static func replacePresented<V: View>(with view: V) -> ViewTransition {
        .init(payload: .replacePresented(with: .init(view)), view: view)
    }
    
    public static var dismiss: ViewTransition {
        .init(payload: .dismiss)
    }
    
    public static func dismissView<H: Hashable>(named name: H) -> ViewTransition {
        .init(payload: .dismissView(named: .init(name)))
    }
    
    public static func push<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .push(.init(view)), view: view)
    }
    
    public static var pop: ViewTransition {
        .init(payload: .pop)
    }
    
    public static func set<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .set(.init(view)), view: view)
    }
    
    public static func setNavigatable<V: View>(_ view: V) -> ViewTransition {
        .init(payload: .setNavigatable(.init(view)), view: view)
    }

    public static func linear(_ transitions: [ViewTransition]) -> ViewTransition {
        .init(payload: .linear(transitions))
    }
    
    public static func linear(_ transitions: ViewTransition...) -> ViewTransition {
        linear(transitions)
    }
    
    public static func dynamic(
        _ body: @escaping () -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    ) -> ViewTransition {
        .init(payload: .dynamic(body))
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
