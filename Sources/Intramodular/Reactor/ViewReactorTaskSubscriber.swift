//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A subscriber that attaches to a `ViewReactorTaskPublisher`.
public class ViewReactorTaskSubscriber<R: ViewReactor>: TaskSubscriber<Void, Error> {
    private var reactor: R
    private var action: R.Action
    private var _cancellable: RetainUntilCancel<CancellableRetain<ViewReactorTaskSubscriber>>!
    private var cancellable: AnyCancellable!
    
    public init(reactor: R, action: R.Action) {
        self.reactor = reactor
        self.action = action
        
        super.init()
        
        self._cancellable = .init(.init(self))
        self.cancellable = .init(_cancellable)
        
        reactor.cancellables.insert(cancellable)
    }
    
    override public func receive(subscription: Task<Void, Error>) {
        subscription.name = .init(action)
        subscription.request(.unlimited)
        
        reactor.environment.taskManager?.taskStarted(subscription)
    }
    
    override public func receive(_ input: Input) -> Subscribers.Demand {
        return .unlimited
    }
    
    override public func receive(completion: Subscribers.Completion<Failure>) {
        reactor.environment.taskManager?.taskEnded(subscription!)
        
        _cancellable.cancel()
        _cancellable = nil
        
        cancellable.cancel()
        cancellable = nil
    }
}
