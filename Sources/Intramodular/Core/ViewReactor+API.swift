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

extension Reactor where Base: InitiableViewReactor {
    public init() {
        self.init(wrappedValue: .init())
    }
}
