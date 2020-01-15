//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ReactorView: ReactorDependentView, View {
    var reactor: Reactor { get }
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
            .environmentObjects(reactor.createEnvironment())
    }
}
