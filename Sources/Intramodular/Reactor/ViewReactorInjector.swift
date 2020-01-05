//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public struct ViewReactorInjector<R: ViewReactor>: ViewModifier {
    @Reactors() var reactors
    
    public let reactor: () -> R
    
    public func body(content: Content) -> some View {
        content.environment(\.viewReactors, reactors.inserting(reactor))
    }
}

// MARK: - Helpers -

@propertyWrapper
public struct InjectedReactor<Reactor: ViewReactor>: DynamicProperty {
    @Reactors() var reactors
    
    public var wrappedValue: Reactor {
        reactors[Reactor.self]!
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
