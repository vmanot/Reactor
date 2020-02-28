//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol ReactorPlan: Hashable {
    
}

// MARK: - Extensions -

extension ReactorPlan {
    public func createTaskName() -> TaskName {
        return .init(self)
    }
}

// MARK: - Helpers -

public enum EmptyReactorPlan: ReactorPlan {
    
}

extension ViewReactor where Plan == EmptyReactorPlan {
    public func taskPlan(for _: Plan) -> ReactorActionTaskPlan<Self> {
        
    }
}
