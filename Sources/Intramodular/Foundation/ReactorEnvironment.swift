//
// Copyright (c) Vatsal Manot
//

import Merge
import Swift
import SwiftUIX

public protocol ReactorEnvironment {
    var taskPipeline: TaskPipeline { get }
    var dispatchIntercepts: [ReactorDispatchIntercept] { get }
}

extension ReactorEnvironment {
    public func intercepts(
        for item: _opaque_ReactorDispatchItem
    ) -> [ReactorDispatchIntercept] {
        dispatchIntercepts.filter({ $0.filter(item) })
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    public struct ReactorEnvironmentKey<R: Reactor>: EnvironmentKey {
        public static var defaultValue: ReactorReference<R>? {
            return nil
        }
    }
    
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
