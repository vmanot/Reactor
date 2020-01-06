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
        let cancellables = reactor.cancellables
        let _cancellable = SingleAssignmentCancellable()
        let cancellable = AnyCancellable(_cancellable)
        
        cancellables.insert(cancellable)
        
        let subscriber = ViewReactorTaskSubscriber<R>(
            taskManager: reactor.environment.taskManager,
            taskName: .init(action),
            receiveEvent: { event in
                DispatchQueue.main.async {
                    self.reactor.reduce(event: event)
                }
            },
            receiveCompletion: { [weak cancellables] completion in
                cancellables?.remove(cancellable)
                
                switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        fatalError()
                }
            }
        )
        
        reactor
            .taskPublisher(for: action)
            .receive(subscriber: subscriber)
        
        return subscriber.subscription!
    }
}
