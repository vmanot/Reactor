//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public enum ViewReactorActionTaskPlan<R: ViewReactor> {
    case linear([R.Action])
    
    public static func linear(_ actions: R.Action...) -> Self {
        .linear(actions)
    }
}
