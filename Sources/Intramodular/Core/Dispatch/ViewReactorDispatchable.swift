//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ViewReactorDispatchable {
    
}

public protocol ViewReactorDispatchable: Hashable {
    
}

extension ViewReactorDispatchable {
    public func createTaskName() -> TaskName {
        return .init(self)
    }
}
