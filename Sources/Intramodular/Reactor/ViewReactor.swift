//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol opaque_ViewReactor {
    func opaque_dispatch(_ action: opaque_ViewReactorAction) -> Task<Void, Error>?
}

extension opaque_ViewReactor where Self: ViewReactor {
    public func opaque_dispatch(_ action: opaque_ViewReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}

public protocol ViewReactor: opaque_ViewReactor, DynamicProperty {
    associatedtype Action: ViewReactorAction where Action.Reactor == Self
    associatedtype Plan: ViewReactorPlan = EmptyViewReactorPlan

    associatedtype ViewNames: Hashable = Never
    
    typealias ActionTaskPublisher = ViewReactorTaskPublisher<Self>
    typealias ActionPlan = ViewReactorActionPlan<Self>

    var environment: ViewReactorEnvironment { get }
    
    func taskPublisher(for _: Action) -> ActionTaskPublisher
    func actionPlan(for _: Plan) -> ViewReactorActionPlan<Self>

    func dispatcher(for _: Action) -> ViewReactorActionDispatcher<Self>
    @discardableResult
    func dispatch(_: Action) -> Task<Void, Error>
    
    func createEnvironment() -> EnvironmentObjects
}

public protocol InitiableViewReactor: ViewReactor {
    init()
}

// MARK: - Implementation -

extension ViewReactor {
    public func createEnvironment() -> EnvironmentObjects {
        .init()
    }
}

// MARK: - Extensions -

extension ViewReactor {
    public var cancellables: Cancellables {
        environment.cancellables
    }
    
    public var injectedReactors: ViewReactors {
        environment.injectedReactors
    }
}
