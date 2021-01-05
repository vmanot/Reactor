//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

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
    public func status(of action: Action) -> TaskStatusDescription? {
        environment
            .taskPipeline[action.createTaskName()]?
            .statusDescription
    }
    
    @inlinable
    public func lastStatus(of action: Action) -> TaskStatusDescription? {
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
