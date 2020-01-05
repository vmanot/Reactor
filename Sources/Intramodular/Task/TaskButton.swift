//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// An interactive control representing a `Task<Success, Error>`.
public struct TaskButton<Success, Error: Swift.Error, Label: View>: View {
    private let completion: (Result<Success, Error>) -> ()
    private let label: (Task<Success, Error>.Status) -> Label
    
    private var makeTask: () -> Task<Success, Error>? = { nil }
    private var taskRenewsOnEnd: Bool = false
    
    @EnvironmentObject var taskManager: TaskManager
    
    @State var taskName: TaskName?
    @State var taskRenewalSubscription: AnyCancellable?
    
    @OptionalObservedObject var currentTask: Task<Success, Error>?
    
    public var body: some View {
        Button(action: trigger) {
            label(currentTask?.status ?? .idle)
        }
    }
    
    public init(
        completion: @escaping (Result<Success, Error>) -> (),
        @ViewBuilder label: @escaping (Task<Success, Error>.Status) -> Label
    ) {
        self.completion = completion
        self.label = label
    }
    
    private func trigger() {
        guard !(currentTask?.status.isTerminal ?? false) else {
            return
        }
        
        acquireTaskIfNecessary()
    }
    
    private func acquireTaskIfNecessary() {
        guard currentTask == nil else {
            return
        }
        
        guard let taskName = taskName, let task = taskManager[taskName] else {
            self.taskName = self.taskName ?? .init(UUID())
            
            let task = makeTask()
            
            taskManager[self.taskName!] = task
            
            return currentTask = task
        }
        
        currentTask = task as? Task<Success, Error>
        
        if taskRenewsOnEnd {
            taskRenewalSubscription = currentTask?
                .objectWillChange
                .filter({ $0.isTerminal })
                .mapTo(nil)
                .assign(to: \.currentTask, on: self)
        }
    }
}
