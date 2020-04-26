//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

@propertyWrapper
public struct ReactorReference<R: Reactor> {
    private var _wrappedValue: () -> R
    
    public var wrappedValue: R {
        return _wrappedValue()
    }
    
    public init(wrappedValue: @autoclosure @escaping () -> R) {
        self._wrappedValue = wrappedValue
    }
    
    public init(wrappedValue: @escaping () -> R) {
        self._wrappedValue = wrappedValue
    }
}
