//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorActionDispatcher<R: ViewReactor>: Publisher {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public let reactor: R
    public let action: R.Action
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        dispatch().receive(subscriber: subscriber)
    }

    public func dispatch() -> Task<Void, Error> {
        let subscriber = ViewReactorTaskSubscriber(reactor: reactor, action: action)
        
        reactor
            .taskPublisher(for: action)
            .receive(subscriber: subscriber)
        
        return subscriber.subscription!
    }
}

// MARK: - Auxiliary Implementation -

extension ViewReactor {
    public func dispatcher(for action: Action) -> ViewReactorActionDispatcher<Self> {
        ViewReactorActionDispatcher(reactor: self, action: action)
    }
    
    @discardableResult
    public func dispatch(_ action: Action) -> Task<Void, Error> {
        dispatcher(for: action).dispatch()
    }
}
