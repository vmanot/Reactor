//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

struct ViewReactorInjector<R: ViewReactor>: ViewModifier {
    @Reactors() var reactors
    
    let reactor: () -> R
    
    func body(content: Content) -> some View {
        content
            .environment(\.viewReactors, reactors.inserting(reactor))
            .insertEnvironmentObjects(reactor().createEnvironmentObjects())
    }
}

// MARK: - Helpers -

@propertyWrapper
public struct InjectedReactor<Reactor: ViewReactor>: DynamicProperty {
    @Reactors() var injectedReactors
    
    public var wrappedValue: Reactor {
        injectedReactors[Reactor.self]!
    }
    
    public init() {
        
    }
}

extension View {
    public func injectReactor<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        modifier(ViewReactorInjector(reactor: reactor))
    }
}
