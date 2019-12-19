//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class OpaqueTask {
    
}

open class Task<Success, Error: Swift.Error>: OpaqueTask, ObservableObject {
    private let lock = OSUnfairLock()
    
    public let cancellables = Cancellables()
    public let objectWillChange = PassthroughSubject<Status, Never>()
    
    private var startTask: ((Task<Success, Error>) -> Void)?
    private var subscriber: AnySubscriber<Output, Failure>!
    
    private var _status: Status = .idle
    
    public var status: Status {
        get {
            lock.synchronize {
                _status
            }
        } set {
            lock.synchronize {
                objectWillChange.send(newValue)
                
                _status = newValue
            }
        }
    }
    
    public required init<S: Subscriber>(
        start: @escaping (Task<Success, Error>) -> (),
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        self.startTask = start
        self.subscriber = .init(subscriber)
    }
    
    public convenience init<S: Subscriber, Artifact>(
        publisher: TaskPublisher<Success, Error, Artifact>,
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        self.init(
            start: {
                (subscriber as! TaskSubscriber<Success, Error, Artifact>)
                    .receive(artifact: publisher.body($0))
            },
            subscriber: subscriber
        )
    }
}

extension Task: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        guard demand != .none else {
            return
        }
        
        startTask?(self)
        startTask = nil
        
        send(.started)
    }
    
    @discardableResult
    private func send(_ input: Output) -> Subscribers.Demand {
        status = .init(input)
        
        return subscriber.receive(input)
    }
    
    private func send(completion input: Output) {
        send(input)
        send(completion: .finished)
    }
    
    private func send(completion: Subscribers.Completion<Failure>) {
        guard !status.isEnded else {
            return
        }
        
        switch completion {
            case .finished:
                break
            case .failure(let failure):
                status = .init(failure)
        }
        
        subscriber.receive(completion: completion)
        subscriber = nil
    }
}

extension Task {
    public func progress(_ progress: Progress?) {
        send(.progress(progress))
    }
    
    public func succeed(with value: Success) {
        send(completion: .success(value))
    }
    
    public func fail(with error: Error) {
        send(completion: .failure(.error(error)))
    }
    
    public func cancel() {
        send(completion: .failure(.canceled))
    }
}
