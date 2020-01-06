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
        if let base = base as? TaskName {
            self = base
        } else {
            self.baseType = .init(type(of: base))
            self.base = .init(base)
        }
    }
}

// MARK: - Helpers -

extension EnvironmentValues {
    public var taskName: TaskName? {
        get {
            self[DefaultEnvironmentKey<TaskName>]
        } set {
            self[DefaultEnvironmentKey<TaskName>] = newValue
        }
    }
}

extension View {
    public func taskName(_ name: TaskName) -> some View {
        environment(\.taskName, name)
    }
    
    public func taskName<H: Hashable>(_ name: H) -> some View {
        taskName(.init(name))
    }
}
