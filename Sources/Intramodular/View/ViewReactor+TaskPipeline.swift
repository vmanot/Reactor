//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor {
    @inlinable
    public var viewReactors: ReactorSet {
        environment.environment.viewReactors
    }
}

extension ReactorView {
    @inlinable
    public var viewReactors: ReactorSet {
        reactor.environment.environment.viewReactors
    }
}

extension ViewReactor {
    @inlinable
    public func activeTaskID(of action: Action) -> some Hashable {
        environment
            .taskPipeline[action.createTaskName()]?
            .id
    }
    
    @inlinable
    public func status(of action: Action) -> OpaqueTask.StatusDescription? {
        environment
            .taskPipeline[action.createTaskName()]?
            .statusDescription
    }
    
    @inlinable
    public func lastStatus(of action: Action) -> OpaqueTask.StatusDescription? {
        environment.taskPipeline.lastStatus(for: action.createTaskName())
    }
    
    @inlinable
    public func cancel(action: Action) {
        environment.taskPipeline[action.createTaskName()]?.cancel()
    }
    
    @inlinable
    public func cancelAllTasks() {
        environment.taskPipeline.cancelAllTasks()
    }
}
