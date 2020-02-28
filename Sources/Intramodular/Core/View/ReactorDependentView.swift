//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import SwiftUI

public protocol ReactorDependentView: View {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

public protocol IndirectReactorDependentView: ReactorDependentView {
    
}

// MARK: - API -

extension ReactorDependentView {
    public var body: some View {
        EnvironmentValueAccessView(\.viewReactors) { viewReactors in
            self.instantiate(from: viewReactors[Reactor.self]!)
        }
    }
    
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .attach(reactor)
    }
}

extension IndirectReactorDependentView {
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .attach(indirect: reactor)
    }
    
    public func instantiate() -> some View {
        EnvironmentValueAccessView(\.viewReactors) { viewReactors in
            self.instantiate(from: viewReactors[Reactor.self]!)
        }
    }
}
