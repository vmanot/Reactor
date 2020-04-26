//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public struct ViewReactors {
    private var value: [ObjectIdentifier: () -> opaque_ViewReactor] = [:]
    
    public init() {
        
    }
    
    public subscript<R: ViewReactor>(_ reactorType: R.Type) -> R? {
        get {
            value[ObjectIdentifier(R.self)]?() as? R
        } set {
            if let newValue = newValue {
                value[ObjectIdentifier(R.self)] = { newValue }
            } else {
                value[ObjectIdentifier(R.self)] = nil
            }
        }
    }
}

extension ViewReactors {
    public mutating func insert<R: ViewReactor>(_ reactor: @escaping () -> R)  {
        value[ObjectIdentifier(R.self)] = reactor
    }
    
    public mutating func insert(_ reactors: ViewReactors) {
        value.merge(reactors.value, uniquingKeysWith: { x, y in x })
    }
}

extension ViewReactors {
    @discardableResult
    public func dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>! {
        let result = value.values.compactMap({ $0().opaque_dispatch(action) })
        
        if result.isEmpty {
            debugPrint("\(action) was not sufficiently handled.")
        } else if result.count > 1 {
            assertionFailure("\(action) was handled more than once.")
        }
        
        return result.first
    }
}

// MARK: - Auxiliary Implementation -

extension ViewReactors {
    public struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = ViewReactors()
    }
}

extension EnvironmentValues {
    public var viewReactors: ViewReactors {
        get {
            self[ViewReactors.EnvironmentKey.self]
        } set {
            self[ViewReactors.EnvironmentKey.self] = newValue
        }
    }
}
