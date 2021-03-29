//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol _opaque_ReactorDispatchItem {
    func createTaskIdentifier() -> TaskIdentifier
}

public protocol ReactorDispatchItem: _opaque_ReactorDispatchItem, Hashable {
    
}

// MARK: - Implementation -

extension ReactorDispatchItem {
    public func createTaskIdentifier() -> TaskIdentifier {
        return .init(self)
    }
}
