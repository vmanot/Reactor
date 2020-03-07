//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public enum ViewRouterError: Error {
    case transitionError(ViewTransition.Error)
    case unknown(Error)
    
    public init(_ error: Error) {
        if let error = error as? ViewTransition.Error {
            self = .transitionError(error)
        } else {
            self = .unknown(error)
        }
    }
}

public protocol ViewRouter: ObservableObject, Presentable {
    associatedtype Route: ViewRoute
    
    func triggerPublisher(for _: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    
    @discardableResult
    func trigger(_: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
}

// MARK: - API -

extension ReactorActionTask {
    public static func trigger<Router: ViewRouter>(
        _ route: Router.Route,
        in router: Router
    ) -> Self {
        Self.action {
            router.trigger(route)
        }
    }
}

extension ReactorActionTask where R: ViewReactor {
    public static func trigger(_ route: R.Router.Route) -> Self {
        Self.action {
            $0.withParameter {
                $0.wrappedValue.router.trigger(route)
            }
        }
    }
}
