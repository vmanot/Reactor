//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension Task {
    public func toSuccessErrorPublisher() -> AnyPublisher<Success, Error> {
        self.compactMap({ Task.Status($0).successValue })
            .mapError({ Task.Status($0).errorValue! })
            .eraseToAnyPublisher()
    }
}
