//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension ViewReactor {
    public func trigger(_ route: Router.Route)  {
        router.trigger(route)
    }
    
    public func triggerTask(for route: Router.Route) -> ActionTask {
        .trigger(route, in: router)
    }
}
