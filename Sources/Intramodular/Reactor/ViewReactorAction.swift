//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol opaque_ViewReactorAction {

}

public protocol ViewReactorAction: opaque_ViewReactorAction {
    associatedtype Reactor: ViewReactor where Reactor.Action == Self
}

/// A control which dispatches a reactor action when triggered.
public struct ReactorActionDispatchButton<Action: ViewReactorAction, Label: View>: View {
    private let label: Label
    private let action: () -> ()
    
    public init(action: Action, reactor: Action.Reactor, label: () -> Label) {
        self.action = { reactor.dispatch(action) }
        self.label = label()
    }
    
    public var body: some View {
        Button(action: action, label: { label })
    }
}

extension ViewReactor {
    public func actionButton<Label: View>(for action: Action, label: () -> Label) -> some View {
        ReactorActionDispatchButton<Action, Label>(action: action, reactor: self, label: label)
    }
}
