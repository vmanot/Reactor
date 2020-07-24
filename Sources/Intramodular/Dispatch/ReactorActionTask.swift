//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public final class ReactorActionTask<R: Reactor>: ParametrizedPassthroughTask<ReactorReference<R>, Void, Error>, ExpressibleByNilLiteral {
    public required convenience init(nilLiteral: ()) {
        self.init(action: { })
    }
    
    override public func didSend(status: Status) {
        withInput {
            if let action = name._cast(to: R.Action.self) {
                $0.wrappedValue.handleStatus(status, for: action)
            }
        }
    }
}

// MARK: - API -

extension ParametrizedPassthroughTask {
    public func withReactor<R: Reactor>(
        _ body: (R) -> ()
    ) -> Void where Input == ReactorReference<R> {
        if let input = input {
            body(input.wrappedValue)
        } else {
            assertionFailure()
        }
    }
}

extension ReactorActionTask {
    public class func error(description: String) -> Self {
        .init { attemptToFulfill in
            attemptToFulfill(.failure(ViewError(description: description)))
        }
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        .init(mapTo(()).eraseError())
    }
}
