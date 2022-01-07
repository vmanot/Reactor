//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow
import SwiftUIX

public final class ReactorActionTask<R: Reactor>: PassthroughTask<Void, Error>, ExpressibleByNilLiteral {
    var reactor: R?
    var action: R.Action?
    
    public required convenience init(nilLiteral: ()) {
        self.init(action: { })
    }
    
    override public func didSend(status: Status) {
        super.didSend(status: status)
        
        if let reactor = reactor, let action = action {
            reactor.handleStatus(status, for: action)
        } else {
            assertionFailure()
        }
    }
}

extension ReactorActionTask {
    public class func failure(_ error: Error) -> Self {
        .init { attemptToFulfill in
            attemptToFulfill(.failure(error))
        }
    }
    
    public class func error(description: String) -> Self {
        .init { attemptToFulfill in
            attemptToFulfill(.failure(CustomStringError(description: description)))
        }
    }
    
    @inlinable
    public static func trigger<Coordinator: ViewCoordinator>(
        _ route: Coordinator.Route,
        in router: Coordinator
    ) -> Self {
        .action {
            router.trigger(route)
        }
    }
}

// MARK: - API -

extension Publisher {
    /// Convert and erase this publisher to a reactor action task.
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        .init(publisher: reduceAndMapTo(()).eraseError())
    }

    /// Convert and erase this publisher to a reactor action task.
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> where Self: SingleOutputPublisher {
        .init(publisher: mapTo(()).eraseError())
    }
}

extension ObservableTask {
    /// Convert and erase this task to a reactor action task.
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        successPublisher.eraseToActionTask()
    }
}
