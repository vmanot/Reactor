//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import Task

extension EnvironmentObjects {
    public mutating func environmentReactor<R: ViewReactor>(_ reactor: ReactorReference<R>) {
        set({ $0.environmentReactor(reactor.wrappedValue) }, forKey: ObjectIdentifier(R.self))
    }
}
