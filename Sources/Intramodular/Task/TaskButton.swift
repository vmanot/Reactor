//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// An interactive control representing a `Task<Success, Error>`.
public struct TaskButton<Success, Error: Swift.Error, Label: View>: View {
    private let action: () -> Task<Success, Error>?
    private let completion: (Result<Success, Error>) -> ()
    private let label: (Task<Success, Error>.Status) -> Label
    
    @Environment(\.taskName) var taskName
    
    @Environment(\.taskDisabled) var taskDisabled
    @Environment(\.taskInterruptible) var taskInterruptible
    @Environment(\.taskRestartable) var taskRestartable
    
    @Environment(\.taskButtonStyle) var taskButtonStyle
    
    @OptionalEnvironmentObject var taskManager: TaskManager?
    @OptionalObservedObject var currentTask: Task<Success, Error>?
    
    public var task: Task<Success, Error>? {
        if let currentTask = currentTask {
            return currentTask
        } else if let taskName = taskName, let task = taskManager?[taskName] as? Task<Success, Error> {
            return task
        } else {
            return nil
        }
    }
    
    public var taskStatus: Task<Success, Error>.Status {
        return task?.status ?? .idle
    }
    
    public var taskStatusDescription: OpaqueTask.StatusDescription {
        return task?.statusDescription ?? .idle
    }
    
    @State var taskRenewalSubscription: AnyCancellable?
    
    public var body: some View {
        return Button(action: trigger) {
            taskButtonStyle.opaque_makeBody(
                configuration: TaskButtonConfiguration(
                    label: label(taskStatus).eraseToAnyView(),
                    isDisabled: taskDisabled,
                    isInterruptible: taskInterruptible,
                    isRestartable: taskRestartable,
                    status: taskStatusDescription
                )
            )
        }
    }
    
    public init(
        action: @escaping () -> Task<Success, Error>,
        completion: @escaping (Result<Success, Error>) -> () = { _ in },
        @ViewBuilder label: @escaping (Task<Success, Error>.Status) -> Label
    ) {
        self.action = { action() }
        self.completion = completion
        self.label = label
    }
    
    public init(
        action: @escaping () -> Task<Success, Error>,
        completion: @escaping (Result<Success, Error>) -> () = { _ in },
        @ViewBuilder label: () -> Label
    ) {
        let _label = label()
        
        self.action = { action() }
        self.completion = completion
        self.label = { _ in _label }
    }
    
    private func trigger() {
        if !taskRestartable && currentTask != nil {
            return
        }
        
        acquireTaskIfNecessary()
    }
    
    private func acquireTaskIfNecessary() {
        if taskInterruptible {
            if let task = action() {
                return currentTask = task
            }
        }
        if let taskName = taskName, let taskManager = taskManager, let task = taskManager[taskName] as? Task<Success, Error> {
            currentTask = task
        } else {
            currentTask = action()
        }
    }
}
