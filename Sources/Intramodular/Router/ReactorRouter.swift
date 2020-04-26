//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

@propertyWrapper
public struct ReactorRouter<C: ViewCoordinator>: DynamicProperty {
    @State var id = UUID()
    @Environment(\.viewReactors) var viewReactors
    
    @OptionalEnvironmentObject public var _wrappedValue0: AnyViewCoordinator<C.Route>?
    @OptionalEnvironmentObject public var _wrappedValue1: C?
    
    public var wrappedValue: C {
        let result = _wrappedValue0?.base ?? _wrappedValue1!
        
        result.environmentBuilder.transformEnvironment({
            $0.viewReactors.insert(self.viewReactors)
        }, withKey: id)
        
        return result as! C
    }
    
    public init() {
        
    }
}
