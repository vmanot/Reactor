//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ViewReactorRepository: DynamicProperty {
    init()
}

@propertyWrapper
public struct Repository<Base: ViewReactorRepository>: DynamicProperty {
    public var wrappedValue: Base
    
    public init(wrappedValue: Base) {
        self.wrappedValue = wrappedValue
    }
    
    public init() {
        self.init(wrappedValue: .init())
    }
}
