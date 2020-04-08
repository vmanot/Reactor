//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor {
    @_optimize(none)
    @inline(never)
    public var environmentBuilder: EnvironmentBuilder {
        get {
            environment.environmentBuilder
        } nonmutating set {
            environment.$environmentBuilder.wrappedValue = newValue
        }
    }
}

extension ViewReactor {
    @inlinable
    public var viewReactors: ViewReactors {
        environment.viewReactors
    }
}

extension ReactorView {
    @inlinable
    public var viewReactors: ViewReactors {
        reactor.environment.viewReactors
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
