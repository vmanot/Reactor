//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

/// A subscriber that attaches to a `ViewReactorTaskPublisher`.
public class ViewReactorTaskSubscriber<R: ViewReactor>: TaskSubscriber<Void, Error> {
    public typealias ActionOrPlan = ViewReactorActionOrPlan<R>
    
    private var reactor: R
    private var dispatchable: ActionOrPlan
    private var cancellable: RetainUntilCancel<CancellableRetain<ViewReactorTaskSubscriber>>!
    
    public init(reactor: R, dispatchable: ActionOrPlan) {
        self.reactor = reactor
        self.dispatchable = dispatchable
        
        super.init()
        
        self.cancellable = .init(.init(self))
        
        reactor.cancellables.insert(.init(cancellable))
    }
    
    override public func receive(task: Task<Void, Error>) {
        task.setName(dispatchable.createTaskName())
        task.insert(into: reactor.environment.taskPipeline!)
        task.request(.unlimited)
    }
    
    override public func receive(_ input: Input) -> Subscribers.Demand {
        .max(1)
    }
    
    override public func receive(completion: Subscribers.Completion<Failure>) {
        cancellable.cancel()
        cancellable = nil
    }
}
