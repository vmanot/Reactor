//
// Copyright (c) Vatsal Manot
//

import Merge
import Swift
import SwiftUIX

public protocol _ReactorContextProtocol<ReactorType>: _CancellablesProviding {
    associatedtype ReactorType: Reactor
    
    @MainActor
    var _actionTasks: _ObservableTaskGroup<ReactorType.Action> { get }
    
    @MainActor
    var _actionIntercepts: [_ReactorActionIntercept] { get }
}

extension _ReactorContextProtocol {
    /// The intercepts for a given dispatch item.
    @MainActor
    public func intercepts(
        for item: any Hashable
    ) -> [_ReactorActionIntercept] {
        _actionIntercepts.filter({ $0.filter(item) })
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    struct _InsertedReactorKey<R: Reactor>: EnvironmentKey {
        static var defaultValue: ReactorReference<R>? {
            return nil
        }
    }
    
    struct __ReactorSetKey: SwiftUI.EnvironmentKey {
        static let defaultValue = _ReactorSet()
    }
    
    public var reactors: _ReactorSet {
        get {
            self[__ReactorSetKey.self]
        } set {
            self[__ReactorSetKey.self] = newValue
        }
    }
    
    public mutating func insert<R: Reactor>(
        reactor: @autoclosure @escaping () -> R
    ) {
        self[_InsertedReactorKey<R>.self] = ReactorReference(_wrappedValue: reactor)
        
        reactors.insert(reactor)
    }
    
    @available(*, deprecated, renamed: "insert(reactor:)")
    public mutating func insertReactor<R: Reactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) {
        insert(reactor: reactor())
    }
    
    public subscript<R: Reactor>(_ reactor: R.Type) -> R? {
        self[_InsertedReactorKey<R>.self]?.wrappedValue ?? reactors[R.self]
    }
}

extension EnvironmentInsertions {
    public mutating func insert<R: ViewReactor>(
        _ reactor: ReactorReference<R>
    ) {
        transformEnvironment(
            { $0.insert(reactor: reactor.wrappedValue) },
            withKey: ObjectIdentifier(R.self)
        )
    }
}
