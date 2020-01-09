//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol opaque_TaskButtonStyle {
    func opaque_makeBody(configuration: TaskButtonConfiguration) -> AnyView
}

public protocol TaskButtonStyle: opaque_TaskButtonStyle {
    associatedtype Body: View
    
    typealias Configuration = TaskButtonConfiguration
    
    func makeBody(configuration: TaskButtonConfiguration) -> Body
}

// MARK: - Implementation -

extension opaque_TaskButtonStyle where Self: TaskButtonStyle {
    public func opaque_makeBody(configuration: TaskButtonConfiguration) -> AnyView {
        return makeBody(configuration: configuration).eraseToAnyView()
    }
}

fileprivate struct TaskButtonStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: opaque_TaskButtonStyle = DefaultTaskButtonStyle()
}

extension EnvironmentValues {
    var taskButtonStyle: opaque_TaskButtonStyle {
        get {
            self[TaskButtonStyleEnvironmentKey]
        } set {
            self[TaskButtonStyleEnvironmentKey] = newValue
        }
    }
}

// MARK: - Auxiliary Implementation -

public struct DefaultTaskButtonStyle: TaskButtonStyle {
    public func makeBody(configuration: TaskButtonConfiguration) -> some View {
        return configuration.label
    }
}

// MARK: - API -

extension View {
    public func taskButtonStyle<Style: TaskButtonStyle>(_ style: Style) -> some View {
        environment(\.taskButtonStyle, style)
    }
}
