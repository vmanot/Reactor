//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct EnvironmentReactor<R: Reactor>: DynamicProperty {
    @Environment(\.self) var environment
    
    public var wrappedValue: R {
        environment[R]!
    }
    
    public init() {
        
    }
}

extension View {
    @inlinable
    public func environmentReactor<R: ObjectReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        transformEnvironment(\.self, transform: { $0.insertReactor(reactor()) })
            .environmentObject(reactor())
    }
    
    @inlinable
    public func environmentReactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        transformEnvironment(\.self, transform: { $0.insertReactor(reactor()) })
    }
}
