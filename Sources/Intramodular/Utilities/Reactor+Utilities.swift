//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

extension ViewReactor {
    public func trigger(_ route: PrimaryCoordinator.Route)  {
        coordinator.trigger(route)
    }
}

extension ReactorActionTask {
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

extension ReactorActionTask where R: ViewReactor {
    @inlinable
    public static func trigger(_ route: R.PrimaryCoordinator.Route) -> Self {
        .action {
            try! $0.withInput {
                $0.wrappedValue.coordinator.trigger(route)
            }
        }
    }
}
