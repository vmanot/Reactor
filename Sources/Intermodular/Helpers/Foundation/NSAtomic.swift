//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@propertyWrapper
struct NSLockAtomic<Value> {
    private let lock = NSLock()
    
    private var _wrappedValue: Value
    
    var wrappedValue: Value {
        get {
            synchronize {
                _wrappedValue
            }
        } set {
            synchronize {
                _wrappedValue = newValue
            }
        }
    }
    
    init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
    
    private func synchronize<Result>(_ body: () -> Result) -> Result {
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        return body()
    }
}
