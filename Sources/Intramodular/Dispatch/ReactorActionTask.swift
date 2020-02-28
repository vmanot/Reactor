//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public final class ReactorActionTask<R: Reactor>: ParametrizedTask<ReactorReference<R>, Void, Error>, ExpressibleByNilLiteral {
    public required convenience init(nilLiteral: ()) {
        self.init(action: { })
    }
    
    override public func didSend(status: Status) {
        
    }
}

extension ReactorActionTask {
    public func unwrapReactor(_ body: (R) -> ()) {
        unwrap {
            body($0.wrappedValue)
        }
    }
}

// MARK: - API -

extension ReactorActionTask {
    public class func error(description: String) -> Self {
        error(ViewError(description: description))
    }
}

extension ReactorActionTask {
    public static func trigger<Router: ViewRouter>(
        _ route: Router.Route,
        in router: Router
    ) -> Self {
        Self.action {
            router.trigger(route)
        }
    }
}

extension ReactorActionTask where R: ViewReactor {
    public static func trigger(_ route: R.Router.Route) -> Self {
        Self.action {
            $0.unwrap {
                $0.wrappedValue.router.trigger(route)
            }
        }
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToActionTask<R: Reactor>() -> ReactorActionTask<R> {
        .init(body: { _ in self.sink() })
    }
}
