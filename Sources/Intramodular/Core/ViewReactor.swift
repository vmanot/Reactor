//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ViewReactor {
    func opaque_dispatch(_ action: opaque_ViewReactorAction) -> Task<Void, Error>?
}

extension opaque_ViewReactor where Self: ViewReactor {
    public func opaque_dispatch(_ action: opaque_ViewReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}

public protocol ViewReactor: opaque_ViewReactor, DynamicViewPresenter, DynamicProperty {
    associatedtype Action: ViewReactorAction
    associatedtype Plan: ViewReactorPlan = EmptyViewReactorPlan
    associatedtype Repository: ViewReactorRepository = EmptyRepository
    associatedtype Router: ViewRouter = EmptyViewRouter
    associatedtype Subview: Hashable = Never
    
    typealias ActionTask = ViewReactorTaskPublisher<Self>
    typealias ActionTaskPlan = ViewReactorActionTaskPlan<Self>
    
    var environment: ViewReactorEnvironment { get }
    var repository: Repository { get }
    var router: Router { get }
    
    /// Perform any necessary setup after the reactor has been initialized.
    func setup()
    
    /// Create an environment builder for this reactor's sub-components.
    func createEnvironmentBuilder() -> EnvironmentBuilder
    
    /// Produce a task for a given action.
    func task(for _: Action) -> ActionTask
    
    /// Dispatch an action.
    @discardableResult
    func dispatch(_: Action) -> Task<Void, Error>
    
    /// Produce a task plan for a given plan.
    func taskPlan(for _: Plan) -> ActionTaskPlan
    
    /// Dispatch an action plan.
    @discardableResult
    func dispatch(_: Plan) -> Task<Void, Error>
}

public protocol InitiableViewReactor: ViewReactor {
    init()
}

// MARK: - Implementation -

extension ViewReactor {
    public func setup() {
        
    }
    
    public func createEnvironmentBuilder() -> EnvironmentBuilder {
        .init()
    }
    
    public func update() {
        environment.update(reactor: .init(wrappedValue: self))
    }
}

extension ViewReactor where Repository == EmptyRepository {
    public var repository: Repository {
        .init()
    }
}

extension ViewReactor where Router == EmptyViewRouter {
    public var router: EmptyViewRouter {
        .init()
    }
}

// MARK: - API -

@propertyWrapper
public struct Reactor<Base: ViewReactor>: DynamicProperty {
    public var wrappedValue: Base
    
    public init(wrappedValue: Base) {
        self.wrappedValue = wrappedValue
    }
}

extension Reactor where Base: InitiableViewReactor {
    public init() {
        self.init(wrappedValue: .init())
    }
}
