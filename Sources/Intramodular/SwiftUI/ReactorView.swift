//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import SwiftUI

public protocol ReactorView: View {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    var reactor: Reactor { get }
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

// MARK: - Implementation

extension ReactorView {
    @inlinable
    public var body: some View {
        makeBody(reactor: reactor)
            .attach(reactor: reactor)
            .onReceive(ReactorDispatchGlobal.shared.objectWillChange) { action in
                if let action = action as? Reactor.Action {
                    reactor.dispatch(action)
                }
            }
    }
}
