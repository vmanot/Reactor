//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public final class ReactorActionTask<R: Reactor>: MutableTask<Void, Error> {
    var reactor: ReactorReference<R>? = nil
    
    public func attach(_ reactor: @autoclosure @escaping () -> R) {
        self.reactor = .init(wrappedValue: reactor())
    }
}
