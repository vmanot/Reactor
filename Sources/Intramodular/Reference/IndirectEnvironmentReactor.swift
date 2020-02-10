//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct IndirectEnvironmentReactor<Reactor: ViewReactor>: DynamicProperty {
    @EnvironmentReactor var base: Reactor
    @OptionalObservedObject var object: ViewReactorEnvironment.Object?
    
    public var wrappedValue: Reactor {
        if object == nil {
            object = base.environment.object
        }
        
        return base
    }
    
    public init() {
        
    }
}
