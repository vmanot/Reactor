//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public struct AttachReactorView<Reactor: ViewReactor, Content: View>: View {
    @usableFromInline
    let reactorReference: ReactorReference<Reactor>
    
    @usableFromInline
    let content: Content
    
    @usableFromInline
    init(reactorReference: ReactorReference<Reactor>, content: Content) {
        self.reactorReference = reactorReference
        self.content = content
    }
    
    public var reactor: Reactor {
        reactorReference.wrappedValue
    }
    
    @_optimize(none)
    @inline(never)
    public var body: some View {
        if !reactor.environment.isSetup { // FIXME?
            DispatchQueue.main.async {
                self.reactor.environment.$isSetup.wrappedValue = true
                self.reactor.setup()
            }
        }
        
        return content
            .environmentReactor(self.reactor)
            .environment(\.taskPipeline, reactor.environment.taskPipeline)
            .environmentObject(reactor.environment.taskPipeline)
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        AttachReactorView(reactorReference: .init(wrappedValue: reactor()), content: self)
    }
}
