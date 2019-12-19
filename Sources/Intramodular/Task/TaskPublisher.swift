//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class TaskPublisher<Success, Error: Swift.Error, Artifact>: Publisher {
    public typealias Output = Task<Success, Error>.Output
    public typealias Failure = Task<Success, Error>.Failure
    
    let body: (Task<Success, Error>) -> Artifact
    
    public init(_ body: @escaping (Task<Success, Error>) -> Artifact) {
        self.body = body
    }
    
    open func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Task(publisher: self, subscriber: subscriber))
    }
    
    open func handleArtifact<S: Subscriber>(
        artifact: Artifact,
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        let subscriber = subscriber as! TaskSubscriber<Success, Error, Artifact>
        
        subscriber.receive(artifact: artifact)
    }
}

extension TaskPublisher where Artifact == Void {
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
            
            _cancellable.set(attemptToFulfill { result in
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
    
    open class func just(_ result: Result<Success, Error>) -> TaskPublisher {
        return .init { attemptToFulfill in
            attemptToFulfill(result)
        }
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToTaskPublisher() -> TaskPublisher<Output, Failure, Void> {
        return .init(self)
    }
}
