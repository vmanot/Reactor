//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol Reactor: opaque_Reactor, Identifiable {
    associatedtype _Environment: ReactorEnvironment
    associatedtype Action: ReactorAction
    associatedtype Plan: ReactorPlan = EmptyReactorPlan
    
    typealias ActionTask = ReactorActionTask<Self>
    typealias ActionTaskPlan = ReactorActionTaskPlan<Self>
    
    var environment: _Environment { get set }
    
    /// Produce a task for a given action.
    func task(for _: Action) -> ActionTask
    
    /// Dispatch an action.
    @discardableResult
    func dispatch(_: Action) -> AnyTask<Void, Error>
    
    /// Produce a task plan for a given plan.
    func taskPlan(for _: Plan) -> ActionTaskPlan
    
    /// Dispatch an action plan.
    @discardableResult
    func dispatch(_: Plan) -> AnyTask<Void, Error>
    
    /// Handle a status produced by a given action.
    func handleStatus(_: ActionTask.Status, for _: Action)
}

// MARK: - Implementation -

extension Reactor where Self: Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(type(of: self))
    }
}

extension Reactor {
    public var inheritedEnvironmentBuilder: EnvironmentBuilder {
        .init()
    }
    
    public func handleStatus(_ status: ActionTask.Status, for action: Action) {
        
    }
}
