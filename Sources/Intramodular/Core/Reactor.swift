//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow
import SwiftUIX

public protocol Reactor: Identifiable {
    associatedtype ReactorContext: _ReactorContextProtocol
    associatedtype Action: Hashable
    
    typealias ActionTask = ReactorActionTask<Self>
    
    var context: ReactorContext { get }
    
    /// Produce a task for a given action.
    @MainActor
    @ReactorActionBuilder<Self>
    func task(for _: Action) -> ActionTask
    
    /// Dispatch an action.
    @discardableResult
    func dispatch(_: Action) -> AnyTask<Void, Error>
}

// MARK: - Implementation

extension Reactor {
    @discardableResult
    @MainActor
    public func dispatch(_ action: Action) -> AnyTask<Void, Error> {
        return ReactorActionDispatcher(reactor: self, action: action).dispatch()
    }
    
    @MainActor
    public func _perform(_ action: Action) async throws {
        try await ReactorActionDispatcher(reactor: self, action: action).dispatch().value
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TaskButton where Success == Void, Error == Swift.Error {
    public init<R: Reactor>(
        _ reactor: R,
        _ action: R.Action,
        @ViewBuilder label: @escaping (TaskStatus<Success, Error>) -> Label
    ) {
        let task = (reactor.context._taskGraph[customTaskIdentifier: action]?.base).flatMap {
            $0 as? any ObservableTask<Success, Error>
        }
        
        self = Self {
            reactor.dispatch(action)
        } label: { status in
            label(status)
        }
        ._existingTask(task)
    }
}

// MARK: - Extensions

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Reactor {
    /// Gets the most recently run task for a given action.
    public func _runningTask(
        for action: Action
    ) -> ActionTask? {
        (context._taskGraph[customTaskIdentifier: action]?.base).map {
            $0 as! ActionTask
        }
    }
}

extension Reactor {
    public func status(
        of query: _ReactorActionStatusQueryExpression<Self, TaskStatusDescription?>
    ) -> TaskStatusDescription? {
        query.rawValue(self)
    }
    
    public func status(of action: Action) -> TaskStatusDescription {
        context._taskGraph[customTaskIdentifier: action]?.statusDescription ?? .idle
    }
    
    private func _customTaskID<T>(
        ofMostRecent action: CasePath<Action, T>
    ) throws -> AnyHashable?  {
        return try context._taskGraph.firstAndOnly(where: {
            guard let customTaskIdentifier = $0.customTaskIdentifier else {
                return false
            }
            
            guard let _action = customTaskIdentifier.base as? Action else {
                assertionFailure()
                
                return false
            }
            
            return try action._opaque_extract(from: _action) != nil
        })?.customTaskIdentifier
    }
    
    public func status(
        ofMostRecent action: Action
    ) -> TaskStatusDescription? {
        _expectedToNotThrow {
            if let status = context._taskGraph[customTaskIdentifier: action]?.statusDescription {
                return status
            } else {
                return context._taskGraph.lastStatus(forCustomTaskIdentifier: action)
            }
        }
    }

    public func status<T>(
        ofMostRecent action: CasePath<Action, T>
    ) -> TaskStatusDescription? {
        _expectedToNotThrow {
            guard let id  = try _customTaskID(ofMostRecent: action) else {
                return nil
            }
            
            if let status = context._taskGraph[customTaskIdentifier: id]?.statusDescription {
                return status
            } else {
                return context._taskGraph.lastStatus(forCustomTaskIdentifier: id)
            }
        }
    }
    
    public func lastStatus(of action: Action) -> TaskStatusDescription? {
        context._taskGraph.lastStatus(forCustomTaskIdentifier: action)
    }
    
    public func cancel(action: Action) {
        context._taskGraph[customTaskIdentifier: action]?.cancel()
    }
    
    public func cancelAllTasks() {
        context._taskGraph.cancelAllTasks()
    }
}

// MARK: - Auxiliary

public struct _ReactorActionStatusQueryExpression<R: Reactor, Result>: Sendable {
    public typealias Action = R.Action
    
    typealias Query = @Sendable (R) -> Result
    
    let rawValue: @Sendable (R) -> Result
    
    init(rawValue: @escaping @Sendable (R) -> Result) {
        self.rawValue = rawValue
    }
    
    public static func last<T>(
        _ action: CasePath<Action, T>
    ) -> Self where Result == TaskStatusDescription? {
        Self(rawValue: { reactor in
            reactor.status(ofMostRecent: action)
        })
    }
}
