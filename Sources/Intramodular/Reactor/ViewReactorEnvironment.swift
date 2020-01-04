//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorEnvironment {
    public let cancellables = Cancellables()
    
    @Reactors() public var reactors
    @Environment(\.dynamicViewPresenter) public var dynamicViewPresenter
    
    public init() {
        
    }
}

extension ViewReactorEnvironment {
    public subscript<R: ViewReactor>(_ reactorType: R.Type) -> R? {
        reactors[reactorType]
    }
}

// MARK: - Helpers -

extension ViewReactor {
    public func dismiss(viewNamed name: ViewNames) {
        environment.dynamicViewPresenter?.dismiss(viewNamed: name)
    }
}
