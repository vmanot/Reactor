//
// Copyright (c) Vatsal Manot
//

import Merge
import Swift
import SwiftUIX
import Task

public protocol ReactorEnvironment {
    var taskPipeline: TaskPipeline { get }
    var dispatchOverrides: [ReactorDispatchOverride] { get }
}
