//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A mutable task.
public class MutableTask<Success, Error: Swift.Error>: Task<Success, Error> {
    public typealias Body = (Self) -> AnyCancellable
    
    private let body: Body
    private var bodyCancellable: SingleAssignmentAnyCancellable
    
    public required init(body: @escaping Body) {
        self.body = body
        self.bodyCancellable = .init()
        
        super.init(pipeline: nil)
    }
    
    public func send(status: Status) {
        if let output = status.output {
            if case .started = output, self.statusDescription == .idle {
                bodyCancellable.set(body(self as! Self))
            }
            statusValueSubject.send(.init(output))
        } else if let failure = status.failure {
            statusValueSubject.send(.init(failure))
        } else {
            assertionFailure()
        }
        
        if status.isTerminal {
            statusValueSubject.send(completion: .finished)
            
            bodyCancellable.cancel()
            cancellables.cancel()
        }
        
        pipeline?.track(self)
    }
    
    /// Start the task.
    public override func start() {
        send(.started)
    }
    
    /// Publishes progress.
    public func progress(_ progress: Progress?) {
        send(status: .progress(progress))
    }
    
    /// Publishes a success.
    public func succeed(with value: Success) {
        send(status: .success(value))
    }
    
    /// Cancel the task.
    public override func cancel() {
        send(status: .canceled)
    }
    
    /// Publishes a failure.
    public func fail(with error: Error) {
        send(status: .error(error))
    }
}

// MARK: - Protocol Implementations -

extension MutableTask: Subject {
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public func send(_ output: Output) {
        send(status: .init(output))
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter failure: The failure to send.
    public func send(_ failure: Failure) {
        send(status: .init(failure))
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    public func send(completion: Subscribers.Completion<Failure>) {
        switch completion {
            case .finished:
                break
            case .failure(let failure):
                send(status: .init(failure))
        }
    }
    
    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }
}
