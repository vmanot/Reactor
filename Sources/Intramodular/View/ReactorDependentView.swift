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

public protocol IndirectReactorDependentView: ReactorDependentView {
    
}

// MARK: - API -

extension ReactorDependentView {
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .attach(reactor)
    }
    
    public func instantiate() -> some View {
        InjectionInstantiatedReactorDependentView(base: self)
    }
}

extension IndirectReactorDependentView {
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .attach(indirect: reactor)
    }
    
    public func instantiate() -> some View {
        IndirectInjectionInstantiatedReactorDependentView(base: self)
    }
}

// MARK: - Helpers -

struct InjectionInstantiatedReactorDependentView<Base: ReactorDependentView>: View {
    let base: Base
    
    @EnvironmentReactor var reactor: Base.Reactor
    
    var body: some View {
        base.instantiate(from: reactor)
    }
}

struct IndirectInjectionInstantiatedReactorDependentView<Base: IndirectReactorDependentView>: View {
    let base: Base
    
    @IndirectEnvironmentReactor var reactor: Base.Reactor
    
    var body: some View {
        base.instantiate(from: reactor)
    }
}
