//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// An opinionated definition of a task.
public class Task<Success, Error: Swift.Error>: OpaqueTask {
    public let cancellables = Cancellables()
    
    var name: TaskName = .init(UUID())
    
    weak var pipeline: TaskPipeline? {
        didSet {
            pipeline?.track(self)
        }
    }
    
    let statusValueSubject = CurrentValueSubject<Status, Never>(.idle)
    
    public var status: Status {
        get {
            statusValueSubject.value
        } set {
            statusValueSubject.value = newValue
        }
    }
    
    public override var statusDescription: StatusDescription {
        return .init(status)
    }
    
    public var isEnded: Bool {
        status.isTerminal
    }
    
    public init(pipeline: TaskPipeline?) {
        self.pipeline = pipeline
    }
    
    public func start() {
        
    }
    
    public func cancel() {
        
    }
}

extension Task {
    public func insert(into pipeline: TaskPipeline) {
        self.pipeline = pipeline
    }
}

// MARK: - Protocol Implementations -

extension Task: ObservableObject {
    public var objectWillChange: AnyPublisher<Status, Never> {
        statusValueSubject.eraseToAnyPublisher()
    }
}

extension Task: Publisher {
    open func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        objectWillChange
            .setFailureType(to: Failure.self)
            .flatMap({ status -> AnyPublisher<Output, Failure> in
                if let output = status.output {
                    return Just(output)
                        .setFailureType(to: Failure.self)
                        .eraseToAnyPublisher()
                } else if let failure = status.failure {
                    return Fail<Output, Failure>(error: failure)
                        .eraseToAnyPublisher()
                } else {
                    return Empty<Output, Failure>()
                        .eraseToAnyPublisher()
                }
            })
            .receive(subscriber: subscriber)
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
