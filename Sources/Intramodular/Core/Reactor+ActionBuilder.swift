//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow

@resultBuilder
public struct ReactorActionBuilder<R: Reactor> {
    public static func buildBlock(_ action: R.ActionTask) -> R.ActionTask {
        action
    }
    
    public static func buildOptional(_ component: R.ActionTask?) -> R.ActionTask {
        component ?? .action({ })
    }
    
    public static func buildEither(first component:  R.ActionTask) -> R.ActionTask {
        component
    }
    
    public static func buildEither(second component:  R.ActionTask) -> R.ActionTask {
        component
    }
}

extension Reactor {
    public func _Action(
        @_implicitSelfCapture _ action: @MainActor @escaping () -> Void
    ) -> ActionTask {
        ActionTask.action {
            withDependencies(from: self) {
                 action()
            }
        }
    }
    
    public func _Action(
        @_implicitSelfCapture _ action: @MainActor @escaping () async throws -> Void
    ) -> ActionTask where Error == Swift.Error {
        ActionTask.action {
            try await withDependencies(from: self) {
                try await action()
            }
        }
    }
}
