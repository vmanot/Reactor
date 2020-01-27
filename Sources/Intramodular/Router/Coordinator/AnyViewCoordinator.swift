//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

open class AnyViewCoordinator<Route: ViewRoute>: ViewCoordinator {
    private let base: Presentable
    
    public var presenter: Presentable? {
        return base.presenter
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            base.environmentBuilder
        } set {
            base.environmentBuilder = newValue
        }
    }
    
    private let transitionImpl: (Route) -> ViewTransition
    private let triggerPublisherImpl: (Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    private let triggerImpl: (Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    
    public init<VC: ViewCoordinator>(_ coordinator: VC) where VC.Route == Route {
        self.base = coordinator
        
        self.transitionImpl = coordinator.transition
        self.triggerPublisherImpl = coordinator.triggerPublisher
        self.triggerImpl = coordinator.trigger
    }
    
    public func transition(for route: Route) -> ViewTransition {
        transitionImpl(route)
    }
    
    @discardableResult
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        triggerPublisherImpl(route)
    }
    
    @discardableResult
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        triggerImpl(route)
    }
}
