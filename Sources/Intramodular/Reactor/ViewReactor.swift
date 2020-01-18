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
    associatedtype Action: ViewReactorAction
    associatedtype Plan: ViewReactorPlan = EmptyViewReactorPlan
    associatedtype Repository: ViewReactorRepository = EmptyViewReactorRepository
    associatedtype Router: ViewRouter = EmptyViewRouter
    associatedtype Subview: Hashable = Never
    
    typealias ActionTask = ViewReactorTaskPublisher<Self>
    typealias ActionTaskPlan = ViewReactorActionTaskPlan<Self>
    
    var environment: ViewReactorEnvironment { get }
    var repository: Repository { get }
    var router: Router { get }
    
    func createEnvironmentObjects() -> EnvironmentObjects
    
    func task(for _: Action) -> ActionTask
    func taskPlan(for _: Plan) -> ActionTaskPlan
    
    @discardableResult
    func dispatch(_: Action) -> Task<Void, Error>
}

public protocol InitiableViewReactor: ViewReactor {
    init()
}

// MARK: - Implementation -

extension ViewReactor where Repository == EmptyViewReactorRepository {
    public var repository: Repository {
        .init()
    }
}

extension ViewReactor where Router == EmptyViewRouter {
    public var router: EmptyViewRouter {
        .init()
    }
}

extension ViewReactor {
    public func createEnvironmentObjects() -> EnvironmentObjects {
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
