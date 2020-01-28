//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

private struct ViewReactorAttacher<Reactor: ViewReactor>: ViewModifier {
    let reactor: () -> Reactor
    
    public func body(content: Content) -> some View {
        content
            .environmentReactorEnvironment(self.reactor().environment)
            .environmentReactor(self.reactor())
    }
}

// MARK: - API -

extension View {
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        modifier(ViewReactorAttacher(reactor: reactor))
    }
}
