//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ViewReactor: opaque_Reactor {

}

public protocol ViewReactor: opaque_ViewReactor, DynamicViewPresenter, Reactor, ViewReactorComponent {
    associatedtype Repository: ViewReactorRepository = EmptyRepository
    associatedtype Router: ViewRouter = EmptyViewRouter
    associatedtype Subview: Hashable = Never
        
    var environment: ViewReactorEnvironment { get set }
    var repository: Repository { get }
    var router: Router { get }
    
    /// Perform any necessary setup after the reactor has been initialized.
    func setup()
    
    /// Create an environment builder for this reactor's sub-components.
    func createEnvironmentBuilder() -> EnvironmentBuilder
    
    /// Produce a task for a given action.
    func task(for _: Action) -> ActionTask
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
