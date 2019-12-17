//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class ViewReactorTaskPublisher<R: ViewReactor>: Publisher {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public typealias Body = (Task<Void, Error>) -> AnyPublisher<R.Event, Error>
    
    private let body: Body
    
    required init(_ body: @escaping Body) {
        self.body = body
    }
    
    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        guard let subscriber = subscriber as? ViewReactorTaskSubscriber<R> else {
            fatalError()
        }
        
        subscriber.receive(
            subscription: Task(
                start: { task in subscriber.receive(publisher: self.body(task)) },
                subscriber: subscriber
            )
        )
    }
}

// MARK: - Extensions -

extension ViewReactorTaskPublisher {
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
}
