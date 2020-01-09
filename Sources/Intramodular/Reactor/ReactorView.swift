//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ReactorView: View {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    var reactor: Reactor { get }
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

extension ReactorView {
    public var injectedReactors: ViewReactors {
        return reactor.environment.injectedReactors
    }
}

extension ReactorView {
    public var body: some View {
        makeBody(reactor: reactor)
            .injectReactorEnvironment(self.reactor.environment)
            .injectReactor(self.reactor)
    }
}