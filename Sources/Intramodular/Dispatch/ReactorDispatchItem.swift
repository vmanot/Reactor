//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol _opaque_ReactorDispatchItem {
    func createTaskName() -> TaskName
}

public protocol ReactorDispatchItem: _opaque_ReactorDispatchItem, Hashable {
    
}

// MARK: - Implementation -

extension ReactorDispatchItem {
    public func createTaskName() -> TaskName {
        return .init(self)
    }
}
