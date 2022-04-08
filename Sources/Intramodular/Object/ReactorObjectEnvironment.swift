//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import SwiftUIX

public final class ReactorObjectEnvironment: ObservableObject, ReactorEnvironment {
    @PublishedObject public var taskPipeline = TaskPipeline()
    
    public var dispatchIntercepts: [ReactorDispatchIntercept] = []
    
    public init() {
        
    }
}
