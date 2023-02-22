//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct EnvironmentReactor<R: Reactor>: DynamicProperty {
    @Environment(\.self) var environment
    
    public var wrappedValue: R {
        environment[R.self]!
    }
    
    public init() {
        
    }
}

extension View {
    public func reactor<R: ReactorObject>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        transformEnvironment(\.self, transform: { $0.insert(reactor: reactor()) })
            .environmentObject(reactor())
    }
    
    public func reactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        transformEnvironment(\.self, transform: { $0.insert(reactor: reactor()) })
    }
    
    @available(*, deprecated, renamed: "reactor(_:)")
    public func environmentReactor<R: ReactorObject>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        self.reactor(reactor())
    }
    
    @available(*, deprecated, renamed: "reactor(_:)")
    public func environmentReactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        self.reactor(reactor())
    }
}
