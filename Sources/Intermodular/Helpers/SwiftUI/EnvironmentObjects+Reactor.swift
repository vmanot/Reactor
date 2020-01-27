//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import Task

extension EnvironmentObjects {
    public mutating func environmentReactor<R: ViewReactor>(_ reactor: ReactorReference<R>) {
        set({ $0.environmentReactor(reactor.wrappedValue) }, forKey: ObjectIdentifier(R.self))
    }
    
    public mutating func environmentReactors(_ reactors: ViewReactors) {
        set({ $0.environment(\.injectedViewReactors, reactors) }, forKey: ObjectIdentifier(ViewReactors.self))
    }
}
