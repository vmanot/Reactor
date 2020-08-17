//
// Copyright (c) Vatsal Manot
//

import Coordinator
import SwiftUIX

@propertyWrapper
public struct ReactorRouter<Router: ViewRouter>: DynamicProperty {
    @Environment(\.viewReactors) private var viewReactors
    
    @State private var id = UUID()
    
    @OptionalEnvironmentObject public var _wrappedValue0: Router?
    @OptionalEnvironmentObject public var _wrappedValue1: AnyViewRouter<Router.Route>?
    @OptionalEnvironmentObject public var _wrappedValue2: AnyViewCoordinator<Router.Route>?
    
    @inline(never)
    public var wrappedValue: Router {
        let result: Any = nil
            ?? _wrappedValue0
            ?? _wrappedValue1?.base
            ?? _wrappedValue2?.base
            ?? OpaqueBaseViewCoordinator
                ._runtimeLookup[ObjectIdentifier(Router.self)]!
                .takeUnretainedValue()
        
        if let result = result as? EnvironmentProvider {
            result.environmentBuilder.transformEnvironment({
                $0.viewReactors.insert(self.viewReactors)
            }, withKey: id)
        }
        
        return result as! Router
    }
    
    public init() {
        
    }
}
