//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension ViewReactor {
    public func triggerTask(for route: Router.Route) -> ActionTask {
        .trigger(route, in: router)
    }
}
