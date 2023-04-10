//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ReactorActionDispatcher<R: Reactor>: Publisher {
    public typealias Output = ObservableTaskOutputPublisher<AnyTask<Void, Error>>.Output
    public typealias Failure = ObservableTaskOutputPublisher<AnyTask<Void, Error>>.Failure
    
    public let reactor: R
    public let action: R.Action
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        Task { @MainActor in
            dispatch().outputPublisher.receive(subscriber: subscriber)
        }
    }
    
    @MainActor
    public func dispatch() -> AnyTask<Void, Error> {
        var task = reactor.task(for: action)
        
        task.reactor = reactor
        task.action = action
        
        reactor
            .environment
            .intercepts(for: action)
            .forEach { override in
                task = override.provide(for: action, task: task)
                
                task.reactor = reactor
                task.action = action
                
                // FIXME!!!: How are the overrides called
            }
        
        reactor.environment.taskPipeline.track(task, withCustomIdentifier: action)
        
        task.start()
        
        return task.eraseToAnyTask()
    }
}

// MARK: - Auxiliary

extension Reactor {    
    @discardableResult
    @MainActor
    public func dispatch(_ action: Action) -> AnyTask<Void, Error> {
        ReactorActionDispatcher(reactor: self, action: action).dispatch()
    }
}
