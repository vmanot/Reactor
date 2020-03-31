//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public struct AttachReactorView<Reactor: ViewReactor, Content: View>: View {
    fileprivate let reactorReference: ReactorReference<Reactor>
    fileprivate let content: Content
      
    public var reactor: Reactor {
        reactorReference.wrappedValue
    }
    
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
            .onReceive(ReactorDispatchGlobal.shared.objectWillChange, perform: { action in
                if let action = action as? Reactor.Action {
                    self.reactor.dispatch(action)
                }
            })
    }
}

// MARK: - API -

extension View {
    @_optimize(none)
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        AttachReactorView(reactorReference: .init(wrappedValue: reactor()), content: self)
    }
}
