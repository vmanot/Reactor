//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol Reactor: Identifiable {
    associatedtype _Environment: ReactorEnvironment
    associatedtype Action: ReactorAction
    
    typealias ActionTask = ReactorActionTask<Self>
    
    var environment: _Environment { get }
    
    /// Produce a task for a given action.
    @MainActor
    func task(for _: Action) -> ActionTask
    
    /// Dispatch an action.
    @discardableResult
    func dispatch(_: Action) -> AnyTask<Void, Error>
}

// MARK: - Implementation

extension Reactor {
    func _opaque_dispatch(_ action: any ReactorAction) -> AnyTask<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}


extension Reactor {
    public var id: ObjectIdentifier {
        ObjectIdentifier(type(of: self))
    }
}

extension Reactor where Self: AnyObject  {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

// MARK: - Extensions

extension Reactor {
    public func status(of action: Action) -> TaskStatusDescription? {
        environment
            .taskPipeline[customTaskIdentifier: action]?
            .statusDescription
    }
    
    public func lastStatus(of action: Action) -> TaskStatusDescription? {
        environment.taskPipeline.lastStatus(forCustomTaskIdentifier: action)
    }
    
    public func cancel(action: Action) {
        environment.taskPipeline[customTaskIdentifier: action]?.cancel()
    }
    
    public func cancelAllTasks() {
        environment.taskPipeline.cancelAllTasks()
    }
}
