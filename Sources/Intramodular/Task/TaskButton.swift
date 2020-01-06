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
    
    private var repeatable: Bool = true
    
    @Environment(\.taskName) var taskName
    @Environment(\.taskButtonStyle) var taskButtonStyle
    
    @OptionalEnvironmentObject var taskManager: TaskManager?
    @OptionalObservedObject var currentTask: Task<Success, Error>?
    
    @State var taskRenewalSubscription: AnyCancellable?
    
    public var body: some View {
        if let taskButtonStyle = taskButtonStyle {
            let view = taskButtonStyle.opaque_makeBody(
                configuration: TaskButtonConfiguration(
                    label: label(currentTask?.status ?? .idle).eraseToAnyView(),
                    status: currentTask?.status
                )
            )
            
            if let view = view {
                return Button(action: trigger) {
                    view
                }
            }
        }
        
        return Button(action: trigger) {
            label(currentTask?.status ?? .idle)
                .eraseToAnyView()
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
        if !repeatable && currentTask != nil {
            return
        }
        
        acquireTaskIfNecessary()
    }
    
    private func acquireTaskIfNecessary() {
        if let taskName = taskName, let taskManager = taskManager, let task = taskManager[taskName] as? Task<Success, Error> {
            currentTask = task
        } else {
            currentTask = action()
        }
    }
}
