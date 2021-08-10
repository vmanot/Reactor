//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow
import SwiftUIX

public final class ReactorActionTask<R: Reactor>: ParametrizedPassthroughTask<ReactorReference<R>, Void, Error>, ExpressibleByNilLiteral {
    public required convenience init(nilLiteral: ()) {
        self.init(action: { })
    }
    
    override public func didSend(status: Status) {
        super.didSend(status: status)
        
        try! withInput {
            if let action = taskIdentifier._cast(to: R.Action.self) {
                $0.wrappedValue.handleStatus(status, for: action)
            }
        }
    }
}

// MARK: - API -

extension ParametrizedPassthroughTask {
    public func withReactor<R: Reactor>(
        _ body: (R) throws -> ()
    ) rethrows -> Void where Input == ReactorReference<R> {
        if let input = input {
            try body(input.wrappedValue)
        } else {
            assertionFailure()
        }
    }
}

extension ReactorActionTask {
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
    
    @inlinable
    public static func trigger(_ route: R.PrimaryCoordinator.Route) -> Self where R: ViewReactor {
        .action {
            try! $0.withInput {
                $0.wrappedValue.coordinator.trigger(route)
            }
        }
    }
}

// MARK: - API -

extension Publisher {
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        .init(publisher: reduceAndMapTo(()).eraseError())
    }
}

extension SingleOutputPublisher {
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        .init(publisher: mapTo(()).eraseError())
    }
}
