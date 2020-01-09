//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

struct TaskDisabledEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

struct TaskInterruptibleEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

struct TaskRestartableEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var taskDisabled: Bool {
        get {
            self[TaskDisabledEnvironmentKey]
        } set {
            self[TaskDisabledEnvironmentKey] = newValue
        }
    }
    
    var taskInterruptible: Bool {
        get {
            self[TaskDisabledEnvironmentKey]
        } set {
            self[TaskDisabledEnvironmentKey] = newValue
        }
    }
    
    var taskRestartable: Bool {
        get {
            self[TaskDisabledEnvironmentKey]
        } set {
            self[TaskDisabledEnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func taskDisabled(_ disabled: Bool) -> some View {
        environment(\.taskDisabled, disabled)
    }
    
    public func taskInterruptible(_ disabled: Bool) -> some View {
        environment(\.taskInterruptible, disabled)
    }
    
    public func taskRestartable(_ disabled: Bool) -> some View {
        environment(\.taskRestartable, disabled)
    }
}
