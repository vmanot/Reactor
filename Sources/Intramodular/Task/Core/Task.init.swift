//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension MutableTask {
    public convenience init(action: @escaping () -> Success) {
        self.init { (task: MutableTask<Success, Error>) in
            task.start()
            task.succeed(with: action())
            
            return .empty()
        }
    }
    
    public convenience init(_ attemptToFulfill: @escaping (@escaping
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
    
    public convenience init(_ attemptToFulfill: @escaping (@escaping
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
}

extension MutableTask {
    public static func just(_ result: Result<Success, Error>) -> MutableTask {
        return MutableTask { attemptToFulfill in
            attemptToFulfill(result)
        }
    }
    
    public static func success(_ success: Success) -> MutableTask {
        .just(.success(success))
    }
    
    public static func error(_ error: Error) -> MutableTask {
        .just(.failure(error))
    }
}

extension Task where Success == Void {
    public static func action(_ action: @escaping () -> Void) -> Task {
        MutableTask(action: action)
    }
}
