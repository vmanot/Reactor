//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public class ViewReactorTaskSubscriber<R: ViewReactor>: TaskSubscriber<Void, Error, AnyPublisher<R.Event, Error>> {
    private var eventSubscriber: ViewReactorEventSubscriber<R>?
    private var receiveEvent: ((R.Event) -> Void)?
    private var receiveTaskOutput: ((Task<Void, Error>.Output) -> Void)?
    private var receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    
    public init(
        receiveEvent: @escaping (R.Event) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        self.receiveEvent = receiveEvent
        self.receiveTaskOutput = { _ in }
        self.receiveCompletion = receiveCompletion
    }
    
    override public func receive(artifact: AnyPublisher<R.Event, Error>) {
        let eventSubscriber = ViewReactorEventSubscriber<R>(parent: self)
        
        artifact.receive(subscriber: eventSubscriber)
        
        self.eventSubscriber = eventSubscriber
    }
    
    override public func receive(subscription: Task<Void, Error>) {
        subscription.request(.unlimited)
    }
    
    override public func receive(_ input: Input) -> Subscribers.Demand {
        receiveTaskOutput?(input)
        
        return .unlimited
    }
    
    public func receive(_ event: R.Event) -> Subscribers.Demand {
        receiveEvent?(event)
        
        return .unlimited
    }
    
    override public func receive(completion: Subscribers.Completion<Failure>) {
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
