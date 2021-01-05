//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ObservedReactor<R: Reactor>: DynamicProperty {
    @ObservedObject var observedObject: AnyObservableObject<Void, Never>
    
    public let reactor: R
}

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
    
    @inlinable
    public var reactor: Reactor {
        reactorReference.wrappedValue
    }
    
    @_optimize(none)
    @inline(never)
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
            .onPreferenceChange(ReactorDispatchIntercept.PreferenceKey.self, perform: {
                self.reactor.environment.dispatchIntercepts = $0
            })
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
