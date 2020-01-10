//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A subscriber that attaches to a `TaskPublisher`.
open class TaskSubscriber<Success, Error: Swift.Error>: Subscriber {
    public typealias Input = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
    
    public internal(set) var subscription: Task<Success, Error>?
    
    public final func receive(subscription: Subscription) {
        let subscription = subscription as! Task<Success, Error>
        
        self.subscription = subscription
        
        subscription.handleEvents(
            receiveOutput: { _ = self.receive($0) },
            receiveCompletion: { self.receive(completion: $0) }
        ).subscribe(storeIn: subscription.cancellables)
        
        receive(subscription: subscription)
    }
    
    open func receive(subscription: Task<Success, Error>) {
        
    }
    
    open func receive(_ input: Input) -> Subscribers.Demand {
        return .unlimited
    }
    
    open func receive(completion: Subscribers.Completion<Failure>) {
        
    }
}
