//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ReactorAction {
    
}

public protocol ReactorAction: opaque_ReactorAction, ReactorDispatchItem {
    
}

// MARK: - Helpers -

/// A control which dispatches a reactor action when triggered.
public struct ReactorDispatchActionButton<Label: View>: View {
    private let action: TaskName
    private let dispatch: () -> Task<Void, Error>
    
    private let label: Label
    
    public init<R: ViewReactor>(
        action: R.Action,
        reactor: R,
        label: () -> Label
    ) {
        self.action = action.createTaskName()
        self.dispatch = { reactor.dispatch(action) }
        self.label = label()
    }
    
    public var body: some View {
        TaskButton(action: dispatch, label: { label })
            .taskName(action)
    }
}

extension ViewReactor {
    @inline(__always)
    public func taskButton<Label: View>(
        for action: Action,
        @ViewBuilder label: () -> Label
    ) -> some View {
        ReactorDispatchActionButton(action: action, reactor: self, label: label)
    }
}
