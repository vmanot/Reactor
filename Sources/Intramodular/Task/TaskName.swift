//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct TaskName: Hashable {
    private let baseType: ObjectIdentifier
    private let base: AnyHashable
    
    public init<H: Hashable>(_ base: H) {
        self.baseType = .init(type(of: base))
        self.base = .init(base)
    }
}
