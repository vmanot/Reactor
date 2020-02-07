//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol ViewCoordinator: ViewRouter {
    func transition(for: Route) -> ViewTransition
}

// MARK: - Implementation -

open class OpaqueBaseViewCoordinator: Presentable {
    public let cancellables = Cancellables()
    
    open var environmentBuilder = EnvironmentBuilder()
    
    open fileprivate(set) var presenter: Presentable?
    open fileprivate(set) var children: [Presentable] = []
    
    public init() {
        
    }
    
    func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        
    }
}

open class BaseViewCoordinator<Route: ViewRoute>: OpaqueBaseViewCoordinator, ViewCoordinator {
    open func addChild(_ presentable: Presentable) {
        presentable.appendEnvironmentObject(AnyViewCoordinator(self))
        presentable.appendEnvironmentBuilder(environmentBuilder)
        
        (presentable as? OpaqueBaseViewCoordinator)?.becomeChild(of: self)
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        presenter = parent
        
        parent.appendEnvironmentObject(AnyViewCoordinator(self))
        
        appendEnvironmentBuilder(parent.environmentBuilder)
        
        children.forEach({ ($0 as? OpaqueBaseViewCoordinator)?.becomeChild(of: self) })
    }
    
    open func transition(for _: Route) -> ViewTransition {
        fatalError()
    }
    
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        Empty().eraseToAnyPublisher()
    }
    
    @discardableResult
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let publisher = triggerPublisher(for: route)
        let result = PassthroughSubject<ViewTransitionContext, ViewRouterError>()
        
        publisher.subscribe(result, storeIn: cancellables)
        
        return result.eraseToAnyPublisher()
    }
    
    public func parent<R, C: BaseViewCoordinator<R>>(ofType type: C.Type) -> C? {
        presenter as? C
    }
}

// MARK: - Auxiliary Implementation -

@propertyWrapper
public struct ReactorRouter<C: ViewCoordinator>: DynamicProperty {
    @EnvironmentReactors() var environmentReactors
    @EnvironmentObject public var _wrappedValue: AnyViewCoordinator<C.Route>
    
    public var wrappedValue: AnyViewCoordinator<C.Route> {
        _wrappedValue.environmentBuilder.transformEnvironment {
            $0.viewReactors.insert(self.environmentReactors)
        }
        
        return _wrappedValue
    }
    
    public init() {
        
    }
}

// MARK: - Helpers -

extension ActionLabelView {
    public init<Coordinator: ViewCoordinator>(
        trigger route: Coordinator.Route,
        in coordinator: Coordinator,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { coordinator.trigger(route) }, label: label)
    }
}

// MARK: - API -

extension ViewReactorTaskPublisher {
    public class func trigger<R: ViewRouter>(_ route: R.Route, in router: R) -> Self {
        return .init(action: {
            router.trigger(route)
        })
    }
}
