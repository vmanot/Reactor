//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorActionDispatcher<R: ViewReactor> {
    public typealias Output = Void
    public typealias Failure = Never
    
    public let reactor: R
    public let action: R.Action
    
    public func dispatch() -> Task<Void, Error> {
        let subscriber = ViewReactorTaskSubscriber(reactor: reactor, action: action)
        
        reactor
            .taskPublisher(for: action)
            .receive(subscriber: subscriber)
        
        return subscriber.subscription!
    }
}
