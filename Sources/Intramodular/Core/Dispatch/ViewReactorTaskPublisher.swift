//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public final class ViewReactorTaskPublisher<R: ViewReactor>: TaskPublisher<Void, Error>, ExpressibleByNilLiteral {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public required convenience init(action: @escaping () throws -> ()) {
        self.init(Deferred(createPublisher: { Just(()).tryMap { try action() } }))
    }
    
    public required convenience init(nilLiteral: ()) {
        self.init(action: { })
    }

    public static func empty() -> ViewReactorTaskPublisher<R> {
        return .init(action: { })
    }
}

extension ViewReactorTaskPublisher {
    public class func error(description: String) -> Self {
        error(ViewError(description: description))
    }
    
    public static func action(_ action: @escaping () throws -> ()) -> Self {
        .init(action: action)
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToActionTask<R: ViewReactor>() -> ViewReactorTaskPublisher<R> {
        .init(mapTo(()).eraseError())
    }
}
