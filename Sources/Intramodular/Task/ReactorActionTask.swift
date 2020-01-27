//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public final class ReactorActionTask<Success, Error: Swift.Error, Reactor: ViewReactor>: MutableTask<Success, Error> {
    var reactor: ReactorReference<Reactor>?
    
    public func attach(_ reactor: @autoclosure @escaping () -> Reactor) {
        self.reactor = .init(wrappedValue: reactor())
    }
}
