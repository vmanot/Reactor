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
    /// The intercepts for a given dispatch item.
    public func intercepts(
        for item: any ReactorDispatchable
    ) -> [ReactorDispatchIntercept] {
        dispatchIntercepts.filter({ $0.filter(item) })
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    public struct ReactorEnvironmentKey<R: Reactor>: EnvironmentKey {
        public static var defaultValue: ReactorReference<R>? {
            return nil
        }
    }
    
    public subscript<R: Reactor>(_ reactor: R.Type) -> R? {
        self[ReactorEnvironmentKey<R>.self]?.wrappedValue ?? reactors[R.self]
    }
    
    public mutating func insert<R: Reactor>(
        reactor: @autoclosure @escaping () -> R
    ) {
        self[ReactorEnvironmentKey<R>.self] = ReactorReference(_wrappedValue: reactor)
        
        reactors.insert(reactor)
    }
    
    @available(*, deprecated, renamed: "insert(reactor:)")
    public mutating func insertReactor<R: Reactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) {
        insert(reactor: reactor())
    }
}

extension EnvironmentInsertions {
    public mutating func insertReactor<R: ViewReactor>(
        _ reactor: ReactorReference<R>
    ) {
        transformEnvironment({ $0.insert(reactor: reactor.wrappedValue) }, withKey: ObjectIdentifier(R.self))
    }
}
