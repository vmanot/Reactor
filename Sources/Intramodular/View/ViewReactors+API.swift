//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorsAccessView<Content: View>: View {
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

// MARK: - API -

extension View {
    @inlinable
    public func onAppear(dispatch action: opaque_ReactorAction) -> some View {
        ViewReactorsAccessView { reactors in
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
