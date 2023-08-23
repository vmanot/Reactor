//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow
import SwiftUIX

public protocol Reactor: Identifiable {
    associatedtype ReactorContext: _ReactorContextProtocol<Self> where ReactorContext.ReactorType == Self
    associatedtype Action: Hashable
    
    typealias ActionTask = ReactorActionTask<Self>
    
    @MainActor
    var context: ReactorContext { get }
    
    /// Produce a task for a given action.
    @MainActor
    @ReactorActionBuilder<Self>
    func task(for _: Action) -> ActionTask
    
    /// Dispatch an action.
    @MainActor
    @discardableResult
    func dispatch(_: Action) -> AnyTask<Void, Error>
}

public protocol ReactorObject: Reactor & ObservableObject {
    
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
        let task = (reactor.context._actionTasks[customIdentifier: action].last?.base).flatMap {
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
@MainActor
extension Reactor {
    /// Gets the most recently run task for a given action.
    public func _mostRecentlyRunTask(
        for action: Action
    ) -> ActionTask? {
        (context._actionTasks[customIdentifier: action].last?.base).map {
            $0 as! ActionTask
        }
    }
}

@MainActor
extension Reactor {
    public func status(
        of query: _ReactorActionStatusQueryExpression<Self, TaskStatusDescription?>
    ) -> TaskStatusDescription? {
        query.rawValue(self)
    }
    
    public func status(
        of action: Action
    ) -> TaskStatusDescription {
        let tasks = context._actionTasks[customIdentifier: action]
        
        assert(tasks.count <= 1)
        
        return tasks.last?.statusDescription ?? .idle
    }
    
    public func cancel(_ action: Action) {
        context._actionTasks.cancelAll(identifiedBy: action)
    }
    
    public func cancelAll() {
        context._actionTasks.cancelAll()
    }
}

// MARK: - Auxiliary

public struct _ReactorActionStatusQueryExpression<R: Reactor, Result>: Sendable {
    public typealias Action = R.Action
    
    typealias Query = @MainActor @Sendable (R) -> Result
    
    let rawValue: @MainActor @Sendable (R) -> Result
    
    init(rawValue: @escaping @MainActor @Sendable (R) -> Result) {
        self.rawValue = rawValue
    }
}

extension _ReactorActionStatusQueryExpression {
    public static func last<T>(
        _ action: CasePath<Action, T>
    ) -> Self where Result == TaskStatusDescription? {
        Self(rawValue: { reactor in
            reactor.status(ofMostRecent: action)
        })
    }
    
    public static func last(
        _ action: Action
    ) -> Self where Result == TaskStatusDescription? {
        Self(rawValue: { reactor in
            reactor.status(ofMostRecent: action)
        })
    }
}

@MainActor
extension Reactor {
    fileprivate func status(
        ofMostRecent action: Action
    ) -> TaskStatusDescription? {
        _expectNoThrow {
            if let status = context._actionTasks[customIdentifier: action].last?.statusDescription {
                return status
            } else {
                return nil
            }
        }
    }
    
    fileprivate func status<T>(
        ofMostRecent action: CasePath<Action, T>
    ) -> TaskStatusDescription? {
        _expectNoThrow { () -> TaskStatusDescription? in
            guard let action = try _activeActions(matchedBy: action).last else {
                return nil
            }
            
            if let status = context._actionTasks[customIdentifier: action].last?.statusDescription {
                return status
            } else {
                return nil
            }
        }
    }
    
    fileprivate func _activeActions<T>(
        matchedBy casePath: CasePath<Action, T>
    ) throws -> [Action] {
        try context._actionTasks.tasks(matchedBy: casePath).compactMap {
            context._actionTasks.customIdentifier(for: $0)
        }
    }
}
