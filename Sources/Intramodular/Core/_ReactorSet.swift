//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A set of `Reactor`s.
public struct _ReactorSet {
    private var value: [ObjectIdentifier: () -> any Reactor] = [:]
    
    public init() {
        
    }
    
    public subscript<R: Reactor>(_ reactorType: R.Type) -> R? {
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
    
    public mutating func insert<R: Reactor>(_ reactor: @escaping () -> R)  {
        value[ObjectIdentifier(R.self)] = reactor
    }
    
    public mutating func insert(_ reactors: _ReactorSet) {
        value.merge(reactors.value, uniquingKeysWith: { x, y in x })
    }
    
    @discardableResult
    @MainActor
    public func dispatch(_ action: any Hashable) -> AnyTask<Void, Error>! {
        let result = value.values.compactMap({ $0()._opaque_dispatch(action) })
        
        if result.isEmpty {
            debugPrint("\(action) was not sufficiently handled.")
        } else if result.count > 1 {
            assertionFailure("\(action) was handled more than once.")
        }
        
        return result.first
    }
}

// MARK: - Auxiliary

extension Reactor {
    @MainActor
    func _opaque_dispatch(_ action: any Hashable) -> AnyTask<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}
