//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactors {
    private var value: [ObjectIdentifier: () -> opaque_ViewReactor] = [:]
    
    public init() {
        
    }
    
    public subscript<R: ViewReactor>(_ reactorType: R.Type) -> R? {
        value[ObjectIdentifier(R.self)]?() as? R
    }
    
    public mutating func insert<R: ViewReactor>(_ reactor: @escaping () -> R)  {
        value[ObjectIdentifier(R.self)] = reactor
    }
    
    public mutating func insert(_ reactors: ViewReactors) {
        for (key, value) in reactors.value {
            self.value[key] = value
        }
    }
    
    public func dispatch(_ action: opaque_ViewReactorAction) {
        value.values.forEach({ _ = $0().opaque_dispatch(action) })
    }
}
