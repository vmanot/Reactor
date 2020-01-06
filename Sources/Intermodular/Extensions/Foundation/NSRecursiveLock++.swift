//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

extension NSRecursiveLock {
    func withCriticalScope<Result>(_ body: () -> Result) -> Result {
        lock()
        
        defer {
            unlock()
        }
        
        return body()
    }
}
