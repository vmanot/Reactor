//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class TaskSubscriber<Success, Error: Swift.Error>: Subscriber {
    public typealias Input = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
    
    public var task: Task<Success, Error>?
    
    public var onReceive: ((Input) -> Void)?
    public var onComplete: ((Subscribers.Completion<Failure>) -> Void)?
    
    public func receive(subscription: Subscription) {
        task = .some(subscription as! Task)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        onReceive?(input)
        
        return .unlimited
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        onComplete?(completion)
    }
}
