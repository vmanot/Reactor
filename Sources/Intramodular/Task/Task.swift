//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class OpaqueTask: CustomCombineIdentifierConvertible {
    public init() {
        
    }
}

/// An opinionated definition of a task.
open class Task<Success, Error: Swift.Error>: OpaqueTask, ObservableObject {
    private let lock = OSUnfairLock()
    
    public let cancellables = Cancellables()
    public let objectWillChange = PassthroughSubject<Status, Never>()
    
    private var _status: Status = .idle
    
    public var status: Status {
        get {
            lock.withCriticalScope {
                _status
            }
        } set {
            lock.withCriticalScope {
                objectWillChange.send(newValue)
                
                _status = newValue
            }
        }
    }
    
    deinit {
        
    }
}

extension Task {
    /// Publish task start.
    public func start() {
        send(.started)
    }
    
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
    
    /// Publish task cancellation.
    public func cancel() {
        send(.canceled)
    }
    
    public func receive(_ status: Status) {
        switch status {
            case .idle:
                fatalError() // FIXME
            case .started:
                request(.max(1))
            case .progress(let progress):
                self.progress(progress)
            case .canceled:
                cancel()
            case .success(let success):
                succeed(with: success)
            case .error(let error):
                fail(with: error)
        }
    }
}

// MARK: - Protocol Implementations -

extension Task: Publisher {
    open func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        objectWillChange
            .prefixUntil(after: { $0.isTerminal })
            .setFailureType(to: Failure.self)
            .flatMap({ status -> AnyPublisher<Output, Failure> in
                if let output = status.output {
                    return Just(output)
                        .setFailureType(to: Failure.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail<Output, Failure>(error: status.failure!)
                        .eraseToAnyPublisher()
                }
            }).receive(subscriber: subscriber)
    }
}

extension Task: Subject {
    public func send(_ value: Output) {
        status = .init(value)
    }
    
    public func send(_ failure: Failure) {
        send(completion: .failure(failure))
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        lock.withCriticalScope {
            if _status.isIdle {
                fatalError()
            }
            
            switch completion {
                case .finished: do {
                    if !_status.isTerminal {
                        fatalError()
                    }
                }
                case .failure(let failure):
                    objectWillChange.send(.init(failure))
                    
                    _status = .init(failure)
            }
        }
    }
    
    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }
}

extension Task: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        guard demand != .none, status.isIdle else {
            return
        }
        
        start()
    }
}

// MARK: - Auxiliary Implementation -

extension Task {
    public func map<T>(_ transform: @escaping (Success) -> T) -> Task<T, Error> {
        let result = Task<T, Error>()
        
        objectWillChange.handleOutput {
            result.receive($0.map(transform))
        }
        .subscribe(storeIn: cancellables)
        
        return result
    }
}
