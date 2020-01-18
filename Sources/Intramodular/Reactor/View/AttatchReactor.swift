//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

private struct AttachReactor<Reactor: ViewReactor, Content: View>: View {
    let reactor: () -> Reactor
    let content: Content
    
    init(reactor: @escaping () -> Reactor, content: Content) {
        self.reactor = reactor
        self.content = content
    }
    
    var body: some View {
        content
            .injectReactorEnvironment(self.reactor().environment)
            .injectReactor(self.reactor())
            .environmentObjects(reactor().createEnvironmentObjects())
    }
}

extension AttachReactor: opaque_NamedView where Content: opaque_NamedView {
    var name: ViewName {
        content.name
    }
}

// MARK: - API -

extension View {
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        AttachReactor(reactor: reactor, content: self)
    }
}
