//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public class ViewReactorTaskSubscriber<R: ViewReactor>: Subscriber {
    public typealias Input = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public var subscription: Task<Void, Error>!
    public var eventSubscriber: ViewReactorEventSubscriber<R>?
    
    public var receiveEvent: ((R.Event) -> Void)?
    public var receiveTaskOutput: ((Task<Void, Error>.Output) -> Void)?
    public var receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    
    public init(
        receiveEvent: @escaping (R.Event) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        self.receiveEvent = receiveEvent
        self.receiveTaskOutput = { _ in }
        self.receiveCompletion = receiveCompletion
    }
    
    public func receive(publisher: AnyPublisher<R.Event, Error>) {
        let eventSubscriber = ViewReactorEventSubscriber<R>(parent: self)
        
        publisher.receive(subscriber: eventSubscriber)
        
        self.eventSubscriber = eventSubscriber
    }
    
    public func receive(subscription: Subscription) {
        self.subscription = .some(subscription as! Task)
        
        subscription.request(.unlimited)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        receiveTaskOutput?(input)
        
        return .unlimited
    }
    
    public func receive(_ event: R.Event) -> Subscribers.Demand {
        receiveEvent?(event)
        
        return .unlimited
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        defer {
            eventSubscriber = nil
        }
        
        receiveCompletion?(completion)
        
        do {
            subscription = nil
            receiveEvent = nil
            receiveTaskOutput = nil
            receiveCompletion = nil
        }
    }
}
