//
// Copyright (c) Vatsal Manot
//

import Merge
import Swift

/// An opaque mirror for `Reactor` used by various runtime mechanisms.
/// You will never need to implement this.
public protocol opaque_Reactor {
    func opaque_dispatch(_ action: opaque_ReactorAction) -> AnyTask<Void, Error>?
    
    func toAnyObservableObject() -> AnyObservableObject<Void, Never>?
}

// MARK: - Implementation -

extension opaque_Reactor where Self: Reactor {
    public func opaque_dispatch(_ action: opaque_ReactorAction) -> AnyTask<Void, Error>? {
        (action as? Action).map(dispatch)
    }
    
    public func toAnyObservableObject() -> AnyObservableObject<Void, Never>? {
        nil
    }
}

extension opaque_Reactor where Self: ObjectReactor {
    public func toAnyObservableObject() -> AnyObservableObject<Void, Never>? {
        nil
    }
}
