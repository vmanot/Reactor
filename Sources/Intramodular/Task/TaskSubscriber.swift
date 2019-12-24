//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A subscriber that attaches to a `TaskPublisher`.
open class TaskSubscriber<Success, Error: Swift.Error, Artifact>: Subscriber {
    public typealias Input = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
        
    public internal(set) var subscription: Task<Success, Error>?
    
    /// Receives the artifact produced by task publisher's body.
    open func receive(artifact: Artifact) {
        
    }
    
    public final func receive(subscription: Subscription) {
        let subscription = subscription as! Task<Success, Error>
        
        self.subscription = subscription
        
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
