//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class ViewReactorTaskPublisher<R: ViewReactor>: TaskPublisher<Void, Error, AnyPublisher<R.Event, Error>> {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
}

// MARK: - Extensions -

extension ViewReactorTaskPublisher {
    public convenience init(action: @escaping () -> ()) {
        self.init {
            Deferred(createPublisher: { Just(action()) })
                .setFailureType(to: Error.self)
                .mapToEmpty()
        }
    }
    
    public convenience init(_ body: @escaping () -> AnyPublisher<R.Event, Error>) {
        self.init { _ in body() }
    }
    
    public convenience init(_ body: @escaping () -> AnyPublisher<R.Event, Never>) {
        self.init { _ in body().setFailureType(to: Error.self).eraseToAnyPublisher() }
    }
    
    public convenience init<P: Publisher>(
        _ body: @escaping () -> P
    ) where P.Output == R.Event, P.Failure == Error {
        self.init { _ in body().eraseToAnyPublisher() }
    }
    
    public convenience init<P: Publisher>(
        _ body: @escaping () -> P
    ) where P.Output == R.Event, P.Failure == Never {
        self.init { _ in body().setFailureType(to: Error.self).eraseToAnyPublisher() }
    }
}

extension ViewReactorTaskPublisher {
    public static func just(_ event: R.Event?) -> ViewReactorTaskPublisher {
        self.init { () -> AnyPublisher<R.Event, Error> in
            if let event = event {
                return Just(event)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Empty()
                    .eraseToAnyPublisher()
            }
        }
    }
    
    public static func empty() -> ViewReactorTaskPublisher {
        just(nil)
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToTaskPublisher<R: ViewReactor>() -> ViewReactorTaskPublisher<R> where Output == R.Event, Failure == Never {
        return .init({ self })
    }
    
    public func eraseToTaskPublisher<R: ViewReactor>() -> ViewReactorTaskPublisher<R> where Output == R.Event, Failure == Error {
        return .init({ self })
    }
}
