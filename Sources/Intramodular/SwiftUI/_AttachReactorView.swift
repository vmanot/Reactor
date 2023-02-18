//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A container view that attaches a reactor to its content.
public struct _AttachReactorView<Reactor: ViewReactor, Content: View>: View {
    let reactorReference: ReactorReference<Reactor>
    let content: Content

    private var reactor: Reactor {
        reactorReference.wrappedValue
    }

    init(reactorReference: ReactorReference<Reactor>, content: Content) {
        self.reactorReference = reactorReference
        self.content = content
    }

    public var body: some View {
        if !reactor.environment.isSetup {
            DispatchQueue.main.async {
                self.reactor.environment.isSetup = true
                self.reactor.setup()
            }
        }

        return content
            .environmentReactor(self.reactor)
            .environment(\.taskPipeline, reactor.environment.taskPipeline)
            .environmentObject(reactor.environment.taskPipeline)
            .onPreferenceChange(ReactorDispatchIntercept.PreferenceKey.self) {
                self.reactor.environment.dispatchIntercepts = $0
            }
    }
}

// MARK: - API

extension View {
    /// Attaches a given reactor to the view hierarchy.
    ///
    /// The given reactor is propagated to all the children of this view through the environment.
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        _AttachReactorView(reactorReference: .init(wrappedValue: reactor()), content: self)
    }
}
