//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX
import Task

public protocol ViewReactor: _opaque_ViewReactor, DynamicProperty, DynamicViewPresenter, Reactor where _Environment == ViewReactorEnvironment {
    associatedtype Repository: ViewReactorRepository = EmptyRepository
    associatedtype Router: ViewRouter = EmptyViewRouter
    associatedtype Subview: Hashable = Never
    
    typealias ReactorEnvironment = ViewReactorEnvironment
    
    var repository: Repository { get }
    var router: Router { get }
    
    /// Perform any necessary setup after the reactor has been initialized.
    func setup()
}

// MARK: - Implementation -

extension ViewReactor {
    public func action(_ action: Action) -> Action {
        action
    }
}

extension ViewReactor where Self: DynamicProperty {
    public mutating func update() {
        let reactor = self
        
        environment.update(reactor: .init(wrappedValue: reactor))
    }
}

extension ViewReactor  {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            environment.environmentBuilder
        } nonmutating set {
            environment.environmentBuilder = newValue
        }
    }
    
    public func setup() {
        
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
