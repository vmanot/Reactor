//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public enum ReactorActionTaskPlan<R: Reactor> {
    case linear([R.Action])
    
    public static func linear(_ actions: R.Action...) -> Self {
        .linear(actions)
    }
}
