//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorEnvironment: DynamicProperty {
    public let cancellables = Cancellables()
    
    @Environment(\.self) var environment
    @Reactors() public var injectedReactors
    @OptionalEnvironmentObject var parentTaskManager: TaskManager?
    @OptionalObservedObject var taskManager: TaskManager!
    @Environment(\.dynamicViewPresenter) public var dynamicViewPresenter
    
    public init() {
        self.taskManager = .init(parent: parentTaskManager)
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
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle
    ) {
        environment.dynamicViewPresenter?.present(
            view,
            onDismiss: onDismiss,
            style: style,
            environment: environment.environment
        )
    }
    
    public func dismiss(viewNamed name: ViewNames) {
        environment.dynamicViewPresenter?.dismiss(viewNamed: name)
    }
}
