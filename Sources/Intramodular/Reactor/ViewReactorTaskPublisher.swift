//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class ViewReactorTaskPublisher<R: ViewReactor>: TaskPublisher<Void, Error> {
    public typealias Output = Task<Void, Error>.Output
    public typealias Failure = Task<Void, Error>.Failure
    
    public convenience init(action: @escaping () -> ()) {
        self.init(Deferred(createPublisher: { Just(action()) })
            .setFailureType(to: Error.self))
    }
    
    public static func empty() -> ViewReactorTaskPublisher<R> {
        return .init(action: { })
    }
}

extension ViewReactorTaskPublisher {
    public class func error(description: String) -> Self {
        error(ViewError(description: description))
    }
}

// MARK: - Helpers -

extension Publisher {
    public func eraseToTaskPublisher<R: ViewReactor>() -> ViewReactorTaskPublisher<R> {
        .init(mapTo(()).eraseError())
    }
}
