//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

public protocol ViewReactor: _opaque_ViewReactor, DynamicProperty, DynamicViewPresenter, Reactor where _Environment == ViewReactorEnvironment {
    associatedtype PrimaryCoordinator: ViewCoordinator = EmptyViewCoordinator
    associatedtype Subview: Hashable = Never
    
    typealias ReactorEnvironment = ViewReactorEnvironment
    
    /// The primary coordinator of the reactor.
    /// This defaults to `EmptyViewCoordinator`.
    var coordinator: PrimaryCoordinator { get }
    
    /// Perform any necessary setup after the reactor has been initialized.
    func setup()
}

// MARK: - Implementation -

extension ViewReactor {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            environment.environmentBuilder
        } nonmutating set {
            environment.environmentBuilder = newValue
        }
    }
    
    public func action(_ action: Action) -> Action {
        action
    }
    
    public mutating func update() {
        let reactor = self
        
        environment.update(reactor: .init(wrappedValue: reactor))
    }
    
    public func setup() {
        
    }
}

extension ViewReactor where PrimaryCoordinator == EmptyViewCoordinator {
    public var coordinator: EmptyViewCoordinator {
        .init()
    }
}
