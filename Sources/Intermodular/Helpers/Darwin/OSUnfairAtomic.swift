//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

@propertyWrapper
struct OSUnfairAtomic<Value> {    
    private let lock = OSUnfairLock()
    
    private var _wrappedValue: Value
    
    var wrappedValue: Value {
        get {
            lock.withCriticalScope {
                _wrappedValue
            }
        } set {
            lock.withCriticalScope {
                _wrappedValue = newValue
            }
        }
    }
    
    init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
}
