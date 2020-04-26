//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ViewReactorRepository: DynamicProperty {
    
}

public protocol InitiableViewReactorRepository: ViewReactorRepository {
    init()
}

// MARK: - API -

@propertyWrapper
public struct ReactorRepository<Base: ViewReactorRepository>: DynamicProperty {
    public var wrappedValue: Base
    
    public init(wrappedValue: Base) {
        self.wrappedValue = wrappedValue
    }
}

extension ReactorRepository where Base: InitiableViewReactorRepository {
    public init() {
        self.init(wrappedValue: .init())
    }
}
