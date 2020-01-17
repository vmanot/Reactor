//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// An opinionated definition of a task.
public class Task<Success, Error: Swift.Error>: OpaqueTask, ObservableObject {
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
    
    public override var statusDescription: StatusDescription {
        return .init(status)
    }
    
    public var name: TaskName? = nil
    
    public init(name: TaskName) {
        self.name = name
    }
    
    public override init() {
        self.name = nil
    }
    
    /// Publish task start.
    public func start() {
        
    }
    
    public func cancel() {
        
    }
}

// MARK: - Extensions -

extension Task {
    public func eraseToSimplePublisher() -> AnyPublisher<Success, Error> {
        self.compactMap({ Task.Status($0).successValue })
            .mapError({ Task.Status($0).errorValue! })
            .eraseToAnyPublisher()
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
        let result = MutableTask<T, Error>()
        
        eraseToAnyPublisher()
            .map({ $0.map(transform) })
            .mapError({ $0.map(transform) })
            .subscribe(result, storeIn: cancellables)
        
        return result
    }
}
