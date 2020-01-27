//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct EnvironmentReactors: DynamicProperty {
    @Environment(\.injectedViewReactors) public private(set) var wrappedValue
    
    public init() {
        
    }
}

@propertyWrapper
public struct EnvironmentReactor<Reactor: ViewReactor>: DynamicProperty {
    @EnvironmentReactors() var environmentReactors
    
    public var wrappedValue: Reactor {
        environmentReactors[Reactor.self]!
    }
    
    public init() {
        
    }
}

extension View {
    public func environmentReactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        transformEnvironment(\.injectedViewReactors) {
            $0.insert(reactor)
        }
        .insertEnvironmentObjects(reactor().createEnvironmentObjects())
    }
    
    public func environmentReactors(
        _ reactors: ViewReactors
    ) -> some View {
        transformEnvironment(\.injectedViewReactors) {
            $0.insert(reactors)
        }
    }
}
