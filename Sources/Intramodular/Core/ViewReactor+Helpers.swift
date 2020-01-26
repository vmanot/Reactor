//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct Reactor<Base: ViewReactor>: DynamicProperty {
    public var wrappedValue: Base
    
    public init(wrappedValue: Base) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Reactors: DynamicProperty {
    @Environment(\.viewReactors) public private(set) var wrappedValue
    
    public init() {
        
    }
}

extension Reactor where Base: InitiableViewReactor {
    public init() {
        self.init(wrappedValue: .init())
    }
}
