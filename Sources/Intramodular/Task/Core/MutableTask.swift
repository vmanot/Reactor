//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public class MutableTask<Success, Error: Swift.Error>: Task<Success, Error> {
    public typealias Body = (MutableTask<Success, Error>) -> AnyCancellable
    
    private let body: Body?
    private var bodyCancellable: AnyCancellable?
    
    public init(body: Body? = nil) {
        self.body = body
    }
    
    /// Publish task start.
    public override func start() {
        bodyCancellable = body?(self)
        
        send(.started)
    }
    
    /// Publish task cancellation.
    public override func cancel() {
        send(.canceled)
    }
}

extension MutableTask {
    /// Publish task progress.
    public func progress(_ progress: Progress?) {
        send(.progress(progress))
    }
    
    /// Publish task success.
    public func succeed(with value: Success) {
        send(.success(value))
    }
    
    /// Publish task failure.
    public func fail(with error: Error) {
        send(.error(error))
    }
}

// MARK: - Protocol Implementations -

extension MutableTask: Subject {
    public func send(_ value: Output) {
        statusValueSubject.send(.init(value))
        
        if value.isTerminal {
            statusValueSubject.send(completion: .finished)
        }
    }
    
    public func send(_ failure: Failure) {
        send(completion: .failure(failure))
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        switch completion {
            case .finished: do {
                if !statusValueSubject.value.isTerminal {
                    assertionFailure()
                }
            }
            case .failure(let failure): do {
                statusValueSubject.send(.init(failure))
            }
        }
        
        statusValueSubject.send(completion: .finished)
    }
    
    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }
}
