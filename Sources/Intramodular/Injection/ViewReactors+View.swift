//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorsView<Content: View>: View {
    @InjectedReactors() private var injectedReactors
    
    public var content: (ViewReactors) -> Content
    
    public init(@ViewBuilder content: @escaping (ViewReactors) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(injectedReactors)
    }
}

extension ViewReactors {
    public struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = ViewReactors()
    }
}

extension EnvironmentValues {
    public var injectedViewReactors: ViewReactors {
        get {
            self[ViewReactors.EnvironmentKey.self]
        } set {
            self[ViewReactors.EnvironmentKey.self] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func onAppear(dispatch action: opaque_ViewReactorAction) -> some View {
        ViewReactorsView { reactors in
            self.onAppear {
                reactors.dispatch(action)
            }
        }
    }
    
    public func onAppear<R: ViewReactor>(dispatch action: R.Action, in reactor: R) -> some View {
        onAppear {
            reactor.dispatch(action)
        }
    }
}
