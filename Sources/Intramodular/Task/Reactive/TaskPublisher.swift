//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class TaskPublisher<Success, Error: Swift.Error>: Publisher {
    public typealias _Success = Success
    public typealias _Error = Error
    public typealias Output = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
    
    let body: (MutableTask<Success, Error>) -> AnyCancellable
    
    public required init(_ body: @escaping (MutableTask<Success, Error>) -> AnyCancellable) {
        self.body = body
    }
    
    open func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        let task = MutableTask<Success, Error>()
        
        start(task)
        
        subscriber.receive(subscription: task)
    }
    
    open func start(_ task: MutableTask<Success, Error>) {
        task.cancellables.insert(body(task))
    }
    
    public required convenience init(action: @escaping () -> Success) {
        self.init { (task: MutableTask<Success, Error>) in
            task.start()
            task.succeed(with: action())
            
            return .empty()
        }
    }
    
    public required convenience init(_ attemptToFulfill: @escaping (@escaping
        (Result<Success, Error>) -> ()) -> Void) {
        self.init { (task: MutableTask<Success, Error>) in
            attemptToFulfill { result in
                switch result {
                    case .success(let value):
                        task.succeed(with: value)
                    case .failure(let value):
                        task.fail(with: value)
                }
            }
            
            return .init(EmptyCancellable())
        }
    }
    
    public required convenience init(_ attemptToFulfill: @escaping (@escaping
        (Result<Success, Error>) -> ()) -> AnyCancellable) {
        self.init { (task: MutableTask<Success, Error>) in
            return attemptToFulfill { result in
                switch result {
                    case .success(let value):
                        task.succeed(with: value)
                    case .failure(let value):
                        task.fail(with: value)
                }
            }
        }
    }
    
    public required convenience init(_ publisher: AnyPublisher<Success, Error>) {
        self.init { attemptToFulfill in
            publisher.sinkResult(attemptToFulfill)
        }
    }
    
    public required convenience init<P: Publisher>(_ publisher: P) where P.Output == Success, P.Failure == Error {
        self.init { attemptToFulfill in
            publisher.sinkResult(attemptToFulfill)
        }
    }
}

extension TaskPublisher {
    open class func just(_ result: Result<Success, Error>) -> Self {
        return .init { attemptToFulfill in
            attemptToFulfill(result)
        }
    }
    
    open class func success(_ success: Success) -> Self {
        .just(.success(success))
    }
    
    open class func error(_ error: Error) -> Self {
        .just(.failure(error))
    }
}
