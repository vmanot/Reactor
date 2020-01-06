//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct TaskButtonConfiguration<Success, Error: Swift.Error> {
    public let label: AnyView
    public let status: Task<Success, Error>.Status?
}
