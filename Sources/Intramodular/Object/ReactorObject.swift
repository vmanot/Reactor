//
// Copyright (c) Vatsal Manot
//

import Merge

public protocol ReactorObject: ObservableObject, Reactor where _Environment == ReactorObjectEnvironment {
    
}

// MARK: - Implementation -

private var reactorEnvironmentKey: UInt8 = 0

extension ReactorObject {
    public var environment: ReactorObjectEnvironment {
        if let result = objc_getAssociatedObject(self, &reactorEnvironmentKey) as? ReactorObjectEnvironment {
            return result
        } else {
            let result = ReactorObjectEnvironment()
            
            objc_setAssociatedObject(self, &reactorEnvironmentKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}
