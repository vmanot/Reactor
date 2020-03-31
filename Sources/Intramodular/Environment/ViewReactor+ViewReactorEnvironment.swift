//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            environment.environmentBuilder
        } nonmutating set {
            environment.$environmentBuilder.wrappedValue = newValue
        }
    }
}

extension ViewReactor {
    public var environmentReactors: ViewReactors {
        environment.environmentReactors
    }
}

extension ReactorView {
    public var environmentReactors: ViewReactors {
        reactor.environment.environmentReactors
    }
}

extension ViewReactor {
    public func activeTaskID(of action: Action) -> some Hashable {
        environment
            .taskPipeline[action.createTaskName()]?
            .id
    }
    
    public func status(of action: Action) -> OpaqueTask.StatusDescription? {
        environment
            .taskPipeline[action.createTaskName()]?
            .statusDescription
    }
    
    public func lastStatus(of action: Action) -> OpaqueTask.StatusDescription? {
        environment.taskPipeline.lastStatus(for: action.createTaskName())
    }
    
    public func cancel(action: Action) {
        environment.taskPipeline[action.createTaskName()]?.cancel()
    }
    
    public func cancelAllTasks() {
        environment.taskPipeline.cancelAllTasks()
    }
}
