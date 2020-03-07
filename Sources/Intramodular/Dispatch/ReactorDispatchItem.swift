//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ReactorDispatchItem {
    
}

public protocol ReactorDispatchItem: Hashable {
    
}

extension ReactorDispatchItem {
    public func createTaskName() -> TaskName {
        return .init(self)
    }
}
