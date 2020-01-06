//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorEnvironment: DynamicProperty {
    public let cancellables = Cancellables()
    
    @Reactors() public var reactors
    @OptionalEnvironmentObject var taskManager: TaskManager?
    @Environment(\.dynamicViewPresenter) public var dynamicViewPresenter
    
    public init() {
        
    }
}

// MARK: - Extensions -

extension ViewReactorEnvironment {
    public subscript<R: ViewReactor>(_ reactorType: R.Type) -> R? {
        reactors[reactorType]
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
            style: style
        )
    }
    
    public func dismiss(viewNamed name: ViewNames) {
        environment.dynamicViewPresenter?.dismiss(viewNamed: name)
    }
}
