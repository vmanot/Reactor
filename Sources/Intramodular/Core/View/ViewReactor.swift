//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ViewReactor {
    func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>?
}

extension opaque_ViewReactor where Self: ViewReactor {
    public func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}

public protocol ViewReactor: opaque_ViewReactor, Reactor, DynamicViewPresenter, DynamicProperty {
    associatedtype Repository: ViewReactorRepository = EmptyRepository
    associatedtype Router: ViewRouter = EmptyViewRouter
    associatedtype Subview: Hashable = Never
    
    typealias ActionTask = ViewReactorTaskPublisher<Self>
    typealias ActionTaskPlan = ReactorActionTaskPlan<Self>
    
    var environment: ViewReactorEnvironment { get set }
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

// MARK: - Implementation -

extension ViewReactor  {
    public func setup() {
        
    }
    
    public func createEnvironmentBuilder() -> EnvironmentBuilder {
        .init()
    }
}

extension ViewReactor where Self: DynamicProperty {
    public mutating func update() {
        let reactor = self
        
        environment.update(reactor: .init(wrappedValue: reactor))
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
