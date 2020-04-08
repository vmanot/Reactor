//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct EnvironmentReactors: DynamicProperty {
    @Environment(\.viewReactors) public var wrappedValue
    
    public init() {
        
    }
}

@propertyWrapper
public struct EnvironmentReactor<Reactor: ViewReactor>: DynamicProperty {
    @Environment(\.viewReactors) var viewReactors
    
    public var wrappedValue: Reactor {
        viewReactors[Reactor.self]!
    }
    
    public init() {
        
    }
}

extension View {
    @inlinable
    public func environmentReactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        transformEnvironment(\.viewReactors) {
            $0.insert(reactor)
        }
        .mergeEnvironmentBuilder(reactor().environmentBuilder)
    }
    
    @inlinable
    public func viewReactors(
        _ reactors: ViewReactors
    ) -> some View {
        transformEnvironment(\.viewReactors) {
            $0.insert(reactors)
        }
    }
}
