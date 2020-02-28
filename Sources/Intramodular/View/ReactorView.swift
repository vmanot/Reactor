//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ReactorView: ReactorDependentView, NamedView {
    var reactor: Reactor { get }
}

extension ReactorView {
    public var environmentReactors: ViewReactors {
        return reactor.environment.environmentReactors
    }
}

extension ReactorView {
    public var body: some View {
        makeBody(reactor: reactor)
            .attach(self.reactor)
    }
}
