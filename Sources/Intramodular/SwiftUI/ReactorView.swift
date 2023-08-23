//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import SwiftUI

/// A view that is essentially a function over a reactor.
public protocol ReactorView: View {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    var reactor: Reactor { get }
    
    @MainActor
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

// MARK: - Implementation

extension ReactorView {
    @inlinable
    @MainActor
    public var body: some View {
        makeBody(reactor: reactor)
            .attach(reactor: reactor)
            .onReceive(_ReactorRuntime.shared.objectWillChange) { action in
                if let action = action as? Reactor.Action {
                    reactor.dispatch(action)
                }
            }
    }
}
