//
// Copyright (c) Vatsal Manot
//

import CombineX
import SwiftUIX

open class OpaqueTask {
    
}

open class Task<Success, Error: Swift.Error>: OpaqueTask, ObservableObject, Subscription {
    public let cancellables = Cancellables()
    
    let lock = OSUnfairLock()
    
    public enum Output {
        case started
        case inactivity
        case activity(Progress?)
        case success(Success)
    }
    
    public enum Failure: Swift.Error {
        case canceled
        case failure(Error)
    }
    
    public enum Status {
        case idle
        case running
        case inactive
        case active(Progress?)
        case success(Success)
        case canceled
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
        start()
    }
    
    deinit {
        
    }
}

extension Task {
    public func start() {
        do {
            status = .running
        }
        
        self.startTask?(self)
        self.startTask = nil
        
        _ = subscriber.receive(.started)
    }
    
    public func inactivity() {
        do {
            status = .inactive
        }
        
        _ = subscriber.receive(.inactivity)
    }
    
    public func activity(_ progress: Progress?) {
        do {
            status = .active(progress)
        }
        
        _ = subscriber.receive(.activity(progress))
    }
    
    public func succeed(with value: Success) {
        do {
            status = .success(value)
        }
        
        _ = subscriber.receive(.success(value))
        
        subscriber.receive(completion: .finished)
        subscriber = nil
    }
    
    public func fail(with value: Error) {
        do {
            status = .failure(value)
        }
        
        subscriber.receive(completion: .failure(.failure(value)))
        subscriber = nil
    }
    
    public func cancel() {
        guard !status.isEnded else {
            return
        }
        
        subscriber.receive(completion: .failure(.canceled))
        subscriber = nil
    }
}
