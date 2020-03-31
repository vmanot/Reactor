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

// MARK: - API -

extension ReactorDependentView {
    @inline(never)
    public var body: some View {
        EnvironmentValueAccessView(\.viewReactors) { viewReactors in
            self.instantiate(from: viewReactors[Reactor.self]!)
        }
    }
    
    @inline(never)
    public func instantiate(from reactor: Reactor) -> some View {
        _SynthesizedReactorViewBody(reactor: reactor, content: makeBody)
    }
}
