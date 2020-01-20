//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ViewReactorPlan: Hashable {
    
}

// MARK: - Extensions -

extension ViewReactorPlan {
    public func createTaskName() -> TaskName {
        return .init(self)
    }
}

// MARK: - Helpers -

public enum EmptyViewReactorPlan: ViewReactorPlan {
    
}

extension ViewReactor where Plan == EmptyViewReactorPlan {
    public func taskPlan(for _: Plan) -> ViewReactorActionTaskPlan<Self> {
        
    }
}
