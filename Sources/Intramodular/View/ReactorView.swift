//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import SwiftUI

public protocol ReactorView: NamedView {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    var reactor: Reactor { get }
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

// MARK: - Implementation -

extension ReactorView {
    @inlinable
    public var body: some View {
        makeBody(reactor: reactor)
            .attach(self.reactor)
    }
}
