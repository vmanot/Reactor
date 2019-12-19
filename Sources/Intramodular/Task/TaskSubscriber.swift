//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class TaskSubscriber<Success, Error: Swift.Error, Artifact>: Subscriber {
    public typealias Input = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
        
    open func receive(artifact: Artifact) {
        
    }
    
    public final func receive(subscription: Subscription) {
        receive(task: subscription as! Task)
    }
    
    open func receive(task: Task<Success, Error>) {
        
    }
    
    open func receive(_ input: Input) -> Subscribers.Demand {
        return .unlimited
    }
    
    open func receive(completion: Subscribers.Completion<Failure>) {
        
    }
}
