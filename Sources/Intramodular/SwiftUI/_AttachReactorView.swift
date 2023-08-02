//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A container view that attaches a reactor to its content.
public struct _AttachReactorView<Reactor: ViewReactor, Content: View>: View {
    let _reactor: ReactorReference<Reactor>
    let content: Content
    
    private var reactor: Reactor {
        _reactor.wrappedValue
    }
    
    init(reactor: ReactorReference<Reactor>, content: Content) {
        self._reactor = reactor
        self.content = content
    }
    
    public var body: some View {
        if !reactor.context.isSetup {
            DispatchQueue.main.async {
                self.reactor.context.isSetup = true
                self.reactor.setup()
            }
        }
        
        return content
            .reactor(self.reactor)
            ._observableTaskGroup(self.reactor.context._actionTasks)
            .onPreferenceChange(_ReactorActionIntercept.PreferenceKey.self) {
                self.reactor.context._actionIntercepts = $0
            }
    }
}

// MARK: - API

extension View {
    /// Attaches a given reactor to the view hierarchy.
    ///
    /// The given reactor is propagated to all the children of this view through the environment.
    public func attach<R: ViewReactor>(
        reactor: @autoclosure @escaping () -> R
    ) -> some View {
        _AttachReactorView(reactor: .init(wrappedValue: reactor()), content: self)
    }
}
