//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public class ViewReactorEventSubscriber<R: ViewReactor>: Subscriber {
    public typealias Input = R.Event
    public typealias Failure = Error
    
    private unowned let parent: ViewReactorTaskSubscriber<R>
    
    private var subscription: Subscription?
    
    public init(parent: ViewReactorTaskSubscriber<R>) {
        self.parent = parent
    }
    
    public func receive(subscription: Subscription) {
        self.subscription = subscription
        self.subscription?.request(.unlimited)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        parent.receive(input)
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
            case .finished:
                parent.subscription?.succeed(with: ())
            case .failure(let error):
                parent.subscription?.fail(with: error)
        }
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
}
