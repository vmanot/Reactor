//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

private struct ViewReactorAttacher<Reactor: ViewReactor, Content: View>: View {
    let reactor: () -> Reactor
    let content: Content
    
    init(reactor: @escaping () -> Reactor, content: Content) {
        self.reactor = reactor
        self.content = content
    }
    
    var body: some View {
        return content
            .environmentReactorEnvironment(self.reactor().environment)
            .environmentReactor(self.reactor())
    }
}

extension ViewReactorAttacher: opaque_NamedView where Content: opaque_NamedView {
    var name: ViewName {
        content.name
    }
}

// MARK: - API -

extension View {
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        ViewReactorAttacher(reactor: reactor, content: self)
    }
}
