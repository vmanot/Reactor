//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public enum ViewReactorActionOrPlan<R: ViewReactor> {
    case action(R.Action)
    case plan(R.Plan)
    
    public func createTaskName() -> TaskName {
        switch self {
            case .action(let action):
                return .init(action)
            case .plan(let plan):
                return plan.createTaskName()
        }
    }
}
