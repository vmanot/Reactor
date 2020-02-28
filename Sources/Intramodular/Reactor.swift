//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_Reactor {
    func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>?
}

public protocol Reactor: opaque_Reactor {
    associatedtype Action: ReactorAction
    associatedtype Plan: ReactorPlan = EmptyReactorPlan
    
    typealias ActionTaskPlan = ReactorActionTaskPlan<Self>
    
    /// Dispatch an action.
    @discardableResult
    func dispatch(_: Action) -> Task<Void, Error>
    
    /// Produce a task plan for a given plan.
    func taskPlan(for _: Plan) -> ActionTaskPlan
    
    /// Dispatch an action plan.
    @discardableResult
    func dispatch(_: Plan) -> Task<Void, Error>
}

// MARK: - Implementation -

extension opaque_Reactor where Self: Reactor {
    public func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}
