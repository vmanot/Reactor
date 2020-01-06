//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol opaque_TaskButtonStyle {
    func opaque_makeBody<S, E: Swift.Error>(configuration: TaskButtonConfiguration<S, E>) -> AnyView? 
}

extension opaque_TaskButtonStyle where Self: TaskButtonStyle {
    public func opaque_makeBody<S, E: Swift.Error>(configuration: TaskButtonConfiguration<S, E>) -> AnyView? {
        guard S.self == Success.self && E.self == Error.self else {
            return nil
        }
        
        return makeBody(configuration: configuration as! TaskButtonConfiguration<Success, Error>).eraseToAnyView()
    }
}

public protocol TaskButtonStyle: opaque_TaskButtonStyle {
    associatedtype Body: View
    associatedtype Success
    associatedtype Error: Swift.Error
    
    func makeBody(configuration: TaskButtonConfiguration<Success, Error>) -> Body
}

// MARK: - Helpers -

extension EnvironmentValues {
    var taskButtonStyle: opaque_TaskButtonStyle? {
        get {
            self[DefaultEnvironmentKey<opaque_TaskButtonStyle>]
        } set {
            self[DefaultEnvironmentKey<opaque_TaskButtonStyle>] = newValue
        }
    }
}

extension View {
    public func taskButtonStyle<Style: TaskButtonStyle>(_ style: Style) -> some View {
        environment(\.taskButtonStyle, style)
    }
}
