//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A mutable task.
public class MutableTask<Success, Error: Swift.Error>: Task<Success, Error> {
    public typealias Body = (MutableTask<Success, Error>) -> AnyCancellable
    
    private let body: Body
    private var bodyCancellable: SingleAssignmentAnyCancellable
    
    public init(body: @escaping Body = { _ in .empty() }) {
        self.body = body
        self.bodyCancellable = .init()
    }
    
    override func didFinish() {
        bodyCancellable.cancel()
        cancellables.cancel()
    }
    
    /// Start the task.
    public override func start() {
        bodyCancellable.set(body(self))
        
        send(.started)
    }
    
    /// Cancel the task.
    public override func cancel() {
        send(.canceled)
    }
}

extension MutableTask {
    /// Publishes progress.
    public func progress(_ progress: Progress?) {
        send(.progress(progress))
    }
    
    /// Publishes a success.
    public func succeed(with value: Success) {
        send(.success(value))
    }
    
    /// Publishes a failure.
    public func fail(with error: Error) {
        send(.error(error))
    }
}

// MARK: - Protocol Implementations -

extension MutableTask: Subject {
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public func send(_ value: Output) {
        statusValueSubject.send(.init(value))
        
        if value.isTerminal {
            statusValueSubject.send(completion: .finished)
        }
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter failure: The failure to send.
    public func send(_ failure: Failure) {
        send(completion: .failure(failure))
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
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
