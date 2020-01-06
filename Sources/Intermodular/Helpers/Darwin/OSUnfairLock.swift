//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

/// An `os_unfair_lock` wrapper.
final class OSUnfairLock {
    private let base: os_unfair_lock_t
    
    init() {
        base = .allocate(capacity: 1)
        base.initialize(to: os_unfair_lock())
    }
    
    deinit {
        base.deinitialize(count: 1)
        base.deallocate()
    }
        
    func withCriticalScope<Result>(_ body: () -> Result) -> Result {
        os_unfair_lock_lock(base)

        defer {
            os_unfair_lock_unlock(base)
        }
        
        return body()
    }
}
