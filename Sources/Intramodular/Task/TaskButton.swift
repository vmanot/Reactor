//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public enum TaskButtonState {
    case inactive
    case active
    case success
    case failure
}

public struct TaskButton<Success, Error: Swift.Error, Label: View>: View {
    @EnvironmentObject var taskLookup: OpaqueTaskLookup
    
    var taskName: AnyHashable?
    
    @State var state: TaskButtonState = .active
    
    private let completion: (Result<Success, Error>) -> ()
    private let label: (TaskButtonState) -> Label
    
    @State var _task: Task<Success, Error>?
    
    public var task: Task<Success, Error> {
        if let taskName = taskName, let task = taskLookup[taskName] as? Task<Success, Error> {
            return task
        } else {
            return _task!
        }
    }
    
    public var body: some View {
        Button(action: trigger) {
            label(state)
        }
    }
    
    public init(
        completion: @escaping (Result<Success, Error>) -> (),
        @ViewBuilder label: @escaping (TaskButtonState) -> Label
    ) {
        self.completion = completion
        self.label = label
    }
    
    public func trigger() {
        
    }
}
