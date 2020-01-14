//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol ReactorDependentView {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    static func makeBody(reactor: Reactor) -> ReactorViewBody
}

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
        Self.makeBody(reactor: reactor)
            .injectReactorEnvironment(self.reactor.environment)
            .injectReactor(self.reactor)
            .environmentObjects(reactor.createEnvironment())
    }
}

extension ViewReactor {
    public func make<V: ReactorDependentView>(_ viewType: V.Type) -> some View where V.Reactor == Self {
        viewType.makeBody(reactor: self)
    }
}
