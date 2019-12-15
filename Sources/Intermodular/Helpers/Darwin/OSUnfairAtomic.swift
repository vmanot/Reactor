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
            lock.synchronize {
                _wrappedValue
            }
        } set {
            lock.synchronize {
                _wrappedValue = newValue
            }
        }
    }
    
    init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
}
