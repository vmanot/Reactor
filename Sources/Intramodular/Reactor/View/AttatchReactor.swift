//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

private struct AttachReactor<Reactor: ViewReactor>: ViewModifier {
    let reactor: () -> Reactor
    
    init(reactor: @escaping () -> Reactor) {
        self.reactor = reactor
    }
    
    func body(content: Content) -> some View {
        content
            .injectReactorEnvironment(self.reactor().environment)
            .injectReactor(self.reactor())
            .environmentObjects(reactor().createEnvironment())
    }
}

// MARK: - API -

extension View {
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        modifier(AttachReactor(reactor: reactor))
    }
}
