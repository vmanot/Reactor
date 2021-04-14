//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import SwiftUIX

public final class ReactorObjectEnvironment: ReactorEnvironment {
    public var taskPipeline = TaskPipeline()
    public var dispatchIntercepts: [ReactorDispatchIntercept] = []
    
    public init() {
        
    }
}
