//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorEnvironment: DynamicProperty {
    public let cancellables = Cancellables()
    
    @Environment(\.self) var environment
    @Reactors() public var injectedReactors
    @OptionalEnvironmentObject var parentTaskPipeline: TaskPipeline?
    @OptionalObservedObject var taskPipeline: TaskPipeline!
    @Environment(\.dynamicViewPresenter) public var dynamicViewPresenter
    
    public init() {
        self.taskPipeline = .init(parent: parentTaskPipeline)
    }
}

// MARK: - Extensions -

extension ViewReactorEnvironment {
    public subscript<R: ViewReactor>(_ reactorType: R.Type) -> R? {
        injectedReactors[reactorType]
    }
}

// MARK: - Helpers -

@propertyWrapper
public struct ReactorEnvironment: DynamicProperty {
    public private(set) var wrappedValue = ViewReactorEnvironment()
    
    public init() {
        
    }
}

extension ViewReactor {
    /// Present a view.
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle = .automatic
    ) {
        environment.dynamicViewPresenter?.present(
            view.attach(self),
            onDismiss: onDismiss,
            style: style
        )
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss() {
        environment.dynamicViewPresenter?.dismiss()
    }
    
    /// Dismiss the view with the given name.
    public func dismiss(viewNamed name: Subview) {
        environment.dynamicViewPresenter?.dismiss(viewNamed: name)
    }
}

extension ViewReactor {
    public func status(of action: Action) -> OpaqueTask.StatusDescription? {
        environment.taskPipeline[.init(action)]?.statusDescription
    }
}
