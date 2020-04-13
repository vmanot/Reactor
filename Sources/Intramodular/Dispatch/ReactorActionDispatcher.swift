//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public struct ReactorActionDispatcher<R: ViewReactor>: Publisher {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public let reactor: R
    public let action: R.Action
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        dispatch().receive(subscriber: subscriber)
    }
    
    public func dispatch() -> Task<Void, Error> {
        let task = reactor.task(for: action)
        
        task.setName(action.createTaskName())
        task.insert(into: reactor.environment.taskPipeline)
        task.receive(.init(wrappedValue: self.reactor))
        task.start()
        
        return task
    }
}

// MARK: - Auxiliary Implementation -

extension ViewReactor {
    public func dispatcher(for action: Action) -> ReactorActionDispatcher<Self> {
        ReactorActionDispatcher(reactor: self, action: action)
    }
    
    @discardableResult
    public func dispatch(_ action: Action) -> Task<Void, Error> {
        dispatcher(for: action).dispatch()
    }
    
    @discardableResult
    public func dispatch(super action: opaque_ReactorAction) -> Task<Void, Error> {
        viewReactors.dispatch(action)
    }
}

extension ViewReactor where Plan == EmptyReactorPlan {
    public func dispatcher(for plan: Plan) -> ReactorActionDispatcher<Self> {
        
    }
    
    @discardableResult
    public func dispatch(_ plan: Plan) -> Task<Void, Error> {
        
    }
}

extension ViewReactor {
    public func environmentDispatch(_ action: opaque_ReactorAction) -> Task<Void, Error> {
        viewReactors.dispatch(action)
    }
}
