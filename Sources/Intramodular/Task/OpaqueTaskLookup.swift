//
// Copyright (c) Vatsal Manot
//

import CombineX
import SwiftUIX

public final class OpaqueTaskLookup: ObservableObject {
    @Published public var value: [AnyHashable: OpaqueTask] = [:]
    
    public init() {
        
    }
    
    public subscript(_ taskName: AnyHashable) -> OpaqueTask? {
        get {
            value[taskName]
        } set {
            value[taskName] = newValue
        }
    }
}
