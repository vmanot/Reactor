//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ReactorPlan: Hashable {
    
}

// MARK: - Helpers -

public enum EmptyReactorPlan: ReactorPlan {
    
}

extension Reactor where Plan == EmptyReactorPlan {
    public func taskPlan(for _: Plan) -> ActionTaskPlan {
        
    }
}
