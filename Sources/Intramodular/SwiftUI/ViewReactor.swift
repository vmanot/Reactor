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
    public var environmentInsertions: EnvironmentInsertions {
        get {
            environment.environmentInsertions
        } nonmutating set {
            environment.environmentInsertions = newValue
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
