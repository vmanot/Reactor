//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public protocol opaque_ViewReactorAction {
    
}

public protocol ViewReactorAction: opaque_ViewReactorAction, Hashable {
    
}

/// A control which dispatches a reactor action when triggered.
public struct ReactorActionDispatchButton<R: ViewReactor, Label: View>: View {
    private let action: R.Action
    private let dispatch: () -> Task<Void, Error>
    
    private let label: Label
    
    public init(action: R.Action, reactor: R, label: () -> Label) {
        self.action = action
        self.dispatch = { reactor.dispatch(action) }
        self.label = label()
    }
    
    public var body: some View {
        TaskButton(action: dispatch, label: { label })
            .taskName(action)
    }
}

extension ViewReactor {
    public func taskButton<Label: View>(
        for action: Action,
        @ViewBuilder label: () -> Label
    ) -> some View {
        ReactorActionDispatchButton(action: action, reactor: self, label: label)
    }
}
