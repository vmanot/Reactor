//
// Copyright (c) Vatsal Manot
//

import Swift

/// An opaque mirror for `Reactor` used by various runtime mechanisms.
/// You will never need to implement this.
public protocol opaque_Reactor {
    func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>?
}

// MARK: - Implementation -

extension opaque_Reactor where Self: Reactor {
    public func opaque_dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}
