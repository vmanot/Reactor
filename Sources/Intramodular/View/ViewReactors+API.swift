//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorsView<Content: View>: View {
    @usableFromInline
    @Environment(\.viewReactors) var viewReactors
    
    public var content: (ViewReactors) -> Content
    
    @inlinable
    public init(@ViewBuilder content: @escaping (ViewReactors) -> Content) {
        self.content = content
    }
    
    @inlinable
    public var body: some View {
        content(viewReactors)
    }
}

extension ViewReactors {
    public struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = ViewReactors()
    }
}

extension EnvironmentValues {
    public var viewReactors: ViewReactors {
        get {
            self[ViewReactors.EnvironmentKey.self]
        } set {
            self[ViewReactors.EnvironmentKey.self] = newValue
        }
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func onAppear(dispatch action: opaque_ReactorAction) -> some View {
        ViewReactorsView { reactors in
            self.onAppear {
                reactors.dispatch(action)
            }
        }
    }
    
    @inlinable
    public func onAppear<R: ViewReactor>(dispatch action: R.Action, in reactor: R) -> some View {
        onAppear {
            reactor.dispatch(action)
        }
    }
}
