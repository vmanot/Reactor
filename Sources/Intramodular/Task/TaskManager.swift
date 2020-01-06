//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class TaskManager: ObservableObject {
    private var queue = DispatchQueue(label: "Reduce.TaskManager")
    
    @Published private var value: [TaskName: OpaqueTask] = [:]
    
    public init() {
        
    }
    
    public subscript(_ taskName: TaskName) -> OpaqueTask? {
        get {
            queue.sync {
                value[taskName]
            }
        } set {
            queue.sync {
                self.value[taskName] = newValue
            }
        }
    }
}
