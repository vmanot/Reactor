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
        return content
            .injectReactorEnvironment(self.reactor().environment)
            .injectReactor(self.reactor())
            .transformPreference(OnReactorInitializationPreferenceKey.self, { actions in
                self.reactor().environment.object.onReactorInitialization = .init(actions)
            })
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
