//
// Copyright (c) Vatsal Manot
//

import Merge
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
