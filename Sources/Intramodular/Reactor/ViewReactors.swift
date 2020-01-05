//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorsView<Content: View>: View {
    @Reactors() private var reactors
    
    public var content: (ViewReactors) -> Content
    
    public init(@ViewBuilder content: @escaping (ViewReactors) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(reactors)
    }
}

public struct ViewReactors {
    private var value: [ObjectIdentifier: () -> opaque_ViewReactor] = [:]
    
    public struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = ViewReactors()
    }
    
    public func inserting<R: ViewReactor>(_ reactor: @escaping () -> R) -> ViewReactors {
        var result = self
        
        result.value[ObjectIdentifier(R.self)] = reactor
        
        return result
    }
    
    public func inserting(_ reactors: ViewReactors) -> ViewReactors {
        var result = self
        
        for (key, value) in reactors.value {
            result.value[key] = value
        }
        
        return result
    }
    
    public subscript<R: ViewReactor>(_ reactorType: R.Type) -> R? {
        value[ObjectIdentifier(R.self)]?() as? R
    }
    
    public func dispatch(_ action: opaque_ViewReactorAction) {
        value.values.forEach({ _ = $0().opaque_dispatch(action) })
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
