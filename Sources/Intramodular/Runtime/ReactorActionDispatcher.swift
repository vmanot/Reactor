//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

struct ReactorActionDispatcher<R: Reactor>: Publisher {
    typealias Output = ObservableTaskOutputPublisher<AnyTask<Void, Error>>.Output
    typealias Failure = ObservableTaskOutputPublisher<AnyTask<Void, Error>>.Failure
    
    let reactor: R
    let action: R.Action
    
    func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        Task { @MainActor in
            dispatch().outputPublisher.receive(subscriber: subscriber)
        }
    }
    
    @MainActor
    func dispatch() -> AnyTask<Void, Error> {
        var task = reactor.task(for: action)
        
        task.reactor = reactor
        task.action = action
        
        _provideOverrides(for: &task)
        
        reactor.context._actionTasks.addTask(task, withCustomIdentifier: action)
        
        task.start()
        
        return task.eraseToAnyTask()
    }
    
    // TODO: Get rid of.
    @MainActor
    private func _provideOverrides(for task: inout ReactorActionTask<R>) {
        reactor.context.intercepts(for: action)
            .forEach { override in
                task = override.provide(for: action, task: task)
                
                task.reactor = reactor
                task.action = action
                
                // FIXME!!!: How are the overrides called
            }
    }
}
