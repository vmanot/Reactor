//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorPlanDispatcher<R: ViewReactor>: Publisher {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public let reactor: R
    public let plan: R.Plan
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        dispatch().receive(subscriber: subscriber)
    }
    
    public func dispatch() -> Task<Void, Error> {
        let subscriber = ViewReactorTaskSubscriber(reactor: reactor, plan: plan)
        
        switch reactor.actionPlan(for: plan) {
            case .linear(let actions): do {
                let publisher = actions
                    .map(reactor.dispatcher(for:))
                    .map({ $0.eraseToAnyPublisher() })
                    .join()
                    .eraseToTaskPublisher() as R.ActionTaskPublisher
                
                publisher.receive(subscriber: subscriber)
            }
        }
        
        return subscriber.subscription!
    }
}
