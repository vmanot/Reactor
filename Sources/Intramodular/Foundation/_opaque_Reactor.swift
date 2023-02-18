//
// Copyright (c) Vatsal Manot
//

import Merge
import Swift

/// An opaque mirror for `Reactor` used by various runtime mechanisms.
/// You will never need to implement this.
public protocol _opaque_Reactor {
    func _opaque_dispatch(_ action: _opaque_ReactorAction) -> AnyTask<Void, Error>?
}

// MARK: - Implementation

extension _opaque_Reactor where Self: Reactor {
    public func _opaque_dispatch(_ action: _opaque_ReactorAction) -> AnyTask<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}
