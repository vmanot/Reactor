//
// Copyright (c) Vatsal Manot
//

import Merge
import Swift
import SwiftUIX

public protocol ReactorEnvironment {
    var taskPipeline: TaskPipeline { get }
    var dispatchIntercepts: [ReactorDispatchIntercept] { get }
}
