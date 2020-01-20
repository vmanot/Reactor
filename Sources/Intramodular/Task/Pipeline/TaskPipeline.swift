//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class TaskPipeline: ObservableObject {
    private weak var parent: TaskPipeline?
    
    @Published private var taskHistory: [TaskName: [OpaqueTask.StatusDescription]] = [:]
    @Published private var taskMap: [TaskName: OpaqueTask] = [:]
    
    public init(parent: TaskPipeline? = nil) {
        self.parent = parent
    }
    
    public subscript(_ taskName: TaskName) -> OpaqueTask? {
        if Thread.isMainThread {
            return taskMap[taskName]
        } else {
            return DispatchQueue.main.sync {
                taskMap[taskName]
            }
        }
    }
    
    func track<Success, Error>(_ task: Task<Success, Error>) {
        DispatchQueue.main.async {
            if task.isEnded {
                self.taskHistory[task.name, default: []].append(task.statusDescription)
                self.taskMap.removeValue(forKey: task.name)
            } else {
                self.taskMap[task.name] = task
            }
        }
    }
}
