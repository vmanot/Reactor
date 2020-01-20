//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorDispatcher<R: ViewReactor>: Publisher {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public let reactor: R
    public let dispatchable: ViewReactorActionOrPlan<R>
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        dispatch().receive(subscriber: subscriber)
    }
    
    public func dispatch() -> Task<Void, Error> {
        let subscriber = ViewReactorTaskSubscriber(reactor: reactor, dispatchable: dispatchable)
        
        switch dispatchable {
            case .plan(let plan): do {
                switch reactor.taskPlan(for: plan) {
                    case .linear(let actions): do {
                        let publisher = actions
                            .map(reactor.dispatcher(for:))
                            .map({ $0.eraseToAnyPublisher() })
                            .join()
                            .eraseToActionTask() as R.ActionTask
                        
                        publisher.receive(subscriber: subscriber)
                    }
                }
            }
            case .action(let action): do {
                reactor
                    .task(for: action)
                    .receive(subscriber: subscriber)
                
                return subscriber.subscription!
            }
        }
        
        return subscriber.subscription!
    }
}

// MARK: - Auxiliary Implementation -

extension ViewReactor {
    public func dispatcher(for plan: Plan) -> ViewReactorDispatcher<Self> {
        ViewReactorDispatcher(reactor: self, dispatchable: .plan(plan))
    }
    
    @discardableResult
    public func dispatch(_ plan: Plan) -> Task<Void, Error> {
        dispatcher(for: plan).dispatch()
    }
    
    public func dispatcher(for action: Action) -> ViewReactorDispatcher<Self> {
        ViewReactorDispatcher(reactor: self, dispatchable: .action(action))
    }
    
    @discardableResult
    public func dispatch(_ plan: Action) -> Task<Void, Error> {
        dispatcher(for: plan).dispatch()
    }
}
