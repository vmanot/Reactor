//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class OpaqueTask {
    
}

open class Task<Success, Error: Swift.Error>: OpaqueTask, ObservableObject, Subscription {
    public let cancellables = Cancellables()
    
    let lock = OSUnfairLock()
    
    public enum Output {
        case started
        case progress(Progress?)
        case success(Success)
    }
    
    public enum Failure: Swift.Error {
        case canceled
        case failure(Error)
    }
    
    public enum Status {
        case idle
        case running
        case progress(Progress?)
        case canceled
        case success(Success)
        case failure(Error)
        
        public var isEnded: Bool {
            switch self {
                case .success, .canceled, .failure:
                    return true
                default:
                    return false
            }
        }
    }
    
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
                objectWillChange.send()
                
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
    
    public convenience init<S: Subscriber>(
        publisher: TaskPublisher<Success, Error>,
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        self.init(start: publisher.body, subscriber: subscriber)
    }
    
    public func request(_ demand: Subscribers.Demand) {
        status = .running
        
        self.startTask?(self)
        self.startTask = nil
        
        _ = subscriber.receive(.started)
    }
    
    @discardableResult
    private func send(_ input: Output) -> Subscribers.Demand {
        subscriber.receive(input)
    }
    
    private func send(completion: Subscribers.Completion<Failure>) {
        guard !status.isEnded else {
            return
        }
        
        subscriber.receive(completion: completion)
        subscriber = nil
    }
}

extension Task {
    public func progress(_ progress: Progress?) {
        status = .progress(progress)
        
        send(.progress(progress))
    }
    
    public func succeed(with value: Success) {
        status = .success(value)
        
        send(.success(value))
        send(completion: .finished)
    }
    
    public func fail(with value: Error) {
        status = .failure(value)
        
        send(completion: .failure(.canceled))
    }
    
    public func cancel() {
        send(completion: .failure(.canceled))
    }
}
