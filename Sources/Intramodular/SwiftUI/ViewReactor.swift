//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

/// A reactor that's meant to be used within a SwiftUI view.
public protocol ViewReactor: DynamicProperty, Reactor where ReactorContext == _ReactorContextDynamicProperty {
    associatedtype Subview: Hashable = Never
    
    // @available(*, deprecated, renamed: "ReactorContext")
    var environment: ReactorContext { get }
    
    // @available(*, deprecated, renamed: "ReactorContext")
    typealias ReactorEnvironment = _ReactorContextDynamicProperty
}

extension ViewReactor {
    public var id: ObjectIdentifier {
        ObjectIdentifier(type(of: self))
    }
}

// MARK: - Implementation

extension ViewReactor {
    public var context: ReactorContext {
        environment
    }
    
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
