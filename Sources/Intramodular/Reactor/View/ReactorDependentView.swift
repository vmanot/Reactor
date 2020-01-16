//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ReactorDependentView {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

// MARK: - API -

extension ReactorDependentView {
    public func instantiate() -> some View {
        InjectionInstantiatedReactorDependentView(base: self)
    }
    
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .injectReactor(reactor)
    }
}

// MARK: - Helpers -

struct InjectionInstantiatedReactorDependentView<Base: ReactorDependentView>: View {
    let base: Base
    
    @InjectedReactor var reactor: Base.Reactor
    
    var body: some View {
        base.instantiate(from: reactor)
    }
}
