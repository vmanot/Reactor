//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class TaskManager: ObservableObject {
    @Published public var value: [TaskName: OpaqueTask] = [:]
    
    public init() {
        
    }
    
    public subscript(_ taskName: TaskName) -> OpaqueTask? {
        get {
            value[taskName]
        } set {
            value[taskName] = newValue
        }
    }
}
