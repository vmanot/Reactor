//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

struct ViewReactorInjector<R: ViewReactor>: ViewModifier {
    @InjectedReactors() var reactors
    
    let reactor: () -> R
    
    func body(content: Content) -> some View {
        content.transformEnvironment(\.injectedViewReactors) {
            $0.insert(self.reactor)
        }
        .insertEnvironmentObjects(reactor().createEnvironmentObjects())
    }
}

// MARK: - Helpers -

@propertyWrapper
public struct InjectedReactors: DynamicProperty {
    @Environment(\.injectedViewReactors) public private(set) var wrappedValue
    
    public init() {
        
    }
}

@propertyWrapper
public struct InjectedReactor<Reactor: ViewReactor>: DynamicProperty {
    @InjectedReactors() var injectedReactors
    
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
