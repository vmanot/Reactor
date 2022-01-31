//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

public protocol ViewReactor: DynamicProperty, Reactor where _Environment == ViewReactorEnvironment {
    associatedtype Subview: Hashable = Never
    
    typealias ReactorEnvironment = ViewReactorEnvironment
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
}

extension ViewReactor {
    public mutating func update() {
        let reactor = self
        
        environment.update(reactor: .init(wrappedValue: reactor))
    }
    
    public func setup() {
        
    }
}
