//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class TaskPublisher<Success, Error: Swift.Error>: Publisher {
    public typealias Output = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
    
    let body: (Task<Success, Error>) -> ()
    
    public init(_ body: @escaping (Task<Success, Error>) -> ()) {
        self.body = body
    }
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Task<Success, Error>.Output, S.Failure == Failure {
        subscriber.receive(subscription: Task(publisher: self, subscriber: subscriber))
    }
}

extension TaskPublisher {
    public convenience init(_ attemptToFulfill: @escaping (@escaping
        (Result<Success, Error>) -> ()) -> Void) {
        self.init { (task: Task<Success, Error>) in
            attemptToFulfill { result in
                switch result {
                    case .success(let value):
                        task.succeed(with: value)
                    case .failure(let value):
                        task.fail(with: value)
                }
            }
        }
    }
    
    public convenience init(_ attemptToFulfill: @escaping (@escaping
        (Result<Success, Error>) -> ()) -> AnyCancellable) {
        self.init { (task: Task<Success, Error>) in
            let _cancellable = SingleAssignmentCancellable()
            let cancellable = AnyCancellable(_cancellable)
            
            task.cancellables.insert(cancellable)
            
            _cancellable.innerCancellable = .init(attemptToFulfill { result in
                switch result {
                    case .success(let value):
                        task.succeed(with: value)
                    case .failure(let value):
                        task.fail(with: value)
                }
                
                task.cancellables.remove(cancellable)
            })
        }
    }
    
    public convenience init(_ publisher: AnyPublisher<Success, Error>) {
        self.init { attemptToFulfill in
            publisher.sinkResult(attemptToFulfill)
        }
    }
    
    public convenience init<P: Publisher>(_ publisher: P) where P.Output == Success, P.Failure == Error {
        self.init { attemptToFulfill in
            publisher.sinkResult(attemptToFulfill)
        }
    }
    
    public static func just(_ result: Result<Success, Error>) -> TaskPublisher {
        return .init { attemptToFulfill in
            attemptToFulfill(result)
        }
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToTaskPublisher() -> TaskPublisher<Output, Failure> {
        return .init(self)
    }
}
