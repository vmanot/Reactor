//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A subscriber that attaches to a `ViewReactorTaskPublisher`.
public class ViewReactorTaskSubscriber<R: ViewReactor>: TaskSubscriber<Void, Error> {
    private var taskManager: TaskManager?
    private var taskName: TaskName
    
    private var receiveTaskOutput: ((Task<Void, Error>.Output) -> Void)?
    private var receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    
    public init(
        taskManager: TaskManager?,
        taskName: TaskName,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        self.taskManager = taskManager
        self.taskName = taskName
        
        self.receiveTaskOutput = { _ in }
        self.receiveCompletion = receiveCompletion
    }
        
    override public func receive(subscription: Task<Void, Error>) {
        subscription.request(.unlimited)
        
        taskManager?[taskName] = subscription
    }
    
    override public func receive(_ input: Input) -> Subscribers.Demand {
        receiveTaskOutput?(input)
        
        return .unlimited
    }
        
    override public func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion?(completion)
        
        do {
            taskManager?[taskName] = nil
            
            receiveTaskOutput = nil
            receiveCompletion = nil
        }
    }
}
