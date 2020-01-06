//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol opaque_ViewReactorAction {
    
}

public protocol ViewReactorAction: opaque_ViewReactorAction, Hashable {
    associatedtype Reactor: ViewReactor where Reactor.Action == Self
}

/// A control which dispatches a reactor action when triggered.
public struct ReactorActionDispatchButton<Action: ViewReactorAction, Label: View>: View {
    private let action: Action
    private let dispatch: () -> Task<Void, Error>
    
    private let label: Label
    
    public init(action: Action, reactor: Action.Reactor, label: () -> Label) {
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
    public func actionButton<Label: View>(
        for action: Action,
        label: () -> Label
    ) -> some View {
        ReactorActionDispatchButton(action: action, reactor: self, label: label)
    }
}
