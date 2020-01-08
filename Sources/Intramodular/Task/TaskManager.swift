//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class TaskManager: ObservableObject {
    private weak var parent: TaskManager?
    
    private var queue = DispatchQueue(label: "Reduce.TaskManager")
    
    @Published private var taskHistory: [TaskName: [OpaqueTask.StatusDescription]] = [:]
    @Published private var taskMap: [TaskName: OpaqueTask] = [:]
    
    public init(parent: TaskManager? = nil) {
        self.parent = parent
    }
    
    public subscript(_ taskName: TaskName) -> OpaqueTask? {
        get {
            queue.sync {
                taskMap[taskName]
            }
        }
    }
    
    public func taskStarted<Success, Error>(_ task: Task<Success, Error>) {
        guard let taskName = task.name else {
            return
        }
        
        queue.sync {
            DispatchQueue.main.async {
                self.taskMap[taskName] = task
            }
        }
    }
    
    public func taskEnded<Success, Error>(_ task: Task<Success, Error>) {
        guard let taskName = task.name else {
            return
        }
        
        queue.sync {
            DispatchQueue.main.async {
                self.taskHistory[taskName, default: []].append(task.statusDescription)
                self.taskMap[taskName] = nil
            }
        }
    }
}
