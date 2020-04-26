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
        self[ReactorEnvironmentKey<R>]?.wrappedValue
    }

    public subscript<R: ViewReactor>(_ reactor: R.Type) -> R? {
        self[ReactorEnvironmentKey<R>]?.wrappedValue ?? viewReactors[R.self]
    }
    
    public mutating func insertReactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) {
        self[ReactorEnvironmentKey<R>] = ReactorReference(wrappedValue: reactor)
        
        viewReactors.insert(reactor)
    }
}
