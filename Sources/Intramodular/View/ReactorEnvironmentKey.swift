//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ReactorEnvironmentKey<R: Reactor>: EnvironmentKey {
    public static var defaultValue: ReactorReference<R>? {
        return nil
    }
}

extension EnvironmentValues {
    public subscript<R: Reactor>(_ reactor: R.Type) -> R? {
        self[ReactorEnvironmentKey<R>]?.wrappedValue ?? viewReactors[R.self]
    }
    
    public mutating func insertReactor<R: Reactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) {
        self[ReactorEnvironmentKey<R>] = ReactorReference(_wrappedValue: reactor)
        
        viewReactors.insert(reactor)
    }
}

extension EnvironmentBuilder {
    public mutating func insertReactor<R: ViewReactor>(
        _ reactor: ReactorReference<R>
    ) {
        transformEnvironment(
            { $0.insertReactor(reactor.wrappedValue) },
            withKey: ObjectIdentifier(R.self)
        )
    }
}
