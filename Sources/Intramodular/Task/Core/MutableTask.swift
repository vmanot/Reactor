//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public class MutableTask<Success, Error: Swift.Error>: Task<Success, Error> {
    /// Publish task start.
    public override func start() {
        send(.started)
    }
    
    /// Publish task progress.
    public func progress(_ progress: Progress?) {
        send(.progress(progress))
    }
    
    /// Publish task success.
    public func succeed(with value: Success) {
        send(.success(value))
    }
    
    /// Publish task failure.
    public func fail(with error: Error) {
        send(.error(error))
    }
    
    /// Publish task cancellation.
    public override func cancel() {
        send(.canceled)
    }
    
    public func receive(_ status: Status) {
        switch status {
            case .idle:
                fatalError() // FIXME
            case .started:
                request(.max(1))
            case .progress(let progress):
                self.progress(progress)
            case .canceled:
                cancel()
            case .success(let success):
                succeed(with: success)
            case .error(let error):
                fail(with: error)
        }
    }
}
