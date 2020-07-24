//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

extension ViewReactor {
    public func trigger(_ route: Router.Route)  {
        router.trigger(route)
    }
}

extension ReactorActionTask {
    @inlinable
    public static func trigger<Router: ViewRouter>(
        _ route: Router.Route,
        in router: Router
    ) -> Self {
        .action {
            router.trigger(route)
        }
    }
}

extension ReactorActionTask where R: ViewReactor {
    @inlinable
    public static func trigger(_ route: R.Router.Route) -> Self {
        .action {
            $0.withInput {
                $0.wrappedValue.router.trigger(route)
            }
        }
    }
}
