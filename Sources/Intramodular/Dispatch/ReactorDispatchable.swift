//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ReactorDispatchable {
    
}

public protocol ReactorDispatchable: Hashable {
    
}

extension ReactorDispatchable {
    public func createTaskName() -> TaskName {
        return .init(self)
    }
}
