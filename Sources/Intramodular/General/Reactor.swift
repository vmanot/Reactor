//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_Reactor {
    func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>?
}

public protocol Reactor: opaque_Reactor, Identifiable {
    associatedtype Action: ReactorAction
    associatedtype Plan: ReactorPlan = EmptyReactorPlan
    
    typealias ActionTask = ReactorActionTask<Self>
    typealias ActionTaskPlan = ReactorActionTaskPlan<Self>
        
    var environment: ViewReactorEnvironment { get set }

    /// Dispatch an action.
    @discardableResult
    func dispatch(_: Action) -> Task<Void, Error>
    
    /// Produce a task plan for a given plan.
    func taskPlan(for _: Plan) -> ActionTaskPlan
    
    /// Dispatch an action plan.
    @discardableResult
    func dispatch(_: Plan) -> Task<Void, Error>
    
    func handleStatus(_: ActionTask.Status, for _: Action)
}

// MARK: - Implementation -

extension opaque_Reactor where Self: Reactor {
    public func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}

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
