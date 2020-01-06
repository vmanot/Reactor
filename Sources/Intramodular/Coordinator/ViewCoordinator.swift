//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol ViewCoordinator: ObservableObject, ViewRouter {
    func transition(for: Route) -> ViewTransition
}

// MARK: - Extensions -

extension ViewCoordinator {
    public func injectingReactors(_ reactors: ViewReactors) -> Self {
        environmentObjects.set({ $0.environment(\.viewReactors, reactors) }, forKey: ObjectIdentifier(ViewReactors.self))
        
        return self
    }
}

// MARK: - Implementation -

open class OpaqueBaseViewCoordinator: Presentable {
    public let cancellables = Cancellables()
    
    open var environmentObjects = EnvironmentObjects()
    
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
        presentable.appendEnvironmentObjects(environmentObjects)
        
        (presentable as? OpaqueBaseViewCoordinator)?.becomeChild(of: self)
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        presenter = parent
        
        parent.appendEnvironmentObject(AnyViewCoordinator(self))
        
        appendEnvironmentObjects(parent.environmentObjects)
        
        children.forEach({ ($0 as? OpaqueBaseViewCoordinator)?.becomeChild(of: self) })
    }
    
    open func transition(for _: Route) -> ViewTransition {
        return .none
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
public struct Coordinator<C: ViewCoordinator>: DynamicProperty {
    @Reactors() var reactors
    @EnvironmentObject public private(set) var _wrappedValue: AnyViewCoordinator<C.Route>
    
    public var wrappedValue: AnyViewCoordinator<C.Route> {
        _wrappedValue.injectingReactors(reactors)
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
