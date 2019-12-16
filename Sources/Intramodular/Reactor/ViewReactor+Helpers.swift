//
// Copyright (c) Vatsal Manot
//

import CombineX
import SwiftUIX

@propertyWrapper
public struct Reactor<Base: ViewReactor>: DynamicProperty {
    private var cancellables = Cancellables()
    private var base: Base
    
    public var wrappedValue: Base {
        get {
            base
        } set {
            base = newValue
        }
    }
    
    public init(wrappedValue base: Base) {
        self.base = base
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
