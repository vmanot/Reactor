//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import SwiftUI

public protocol ReactorView: NamedView where Body == _SynthesizedReactorViewBody<Reactor, ReactorViewBody> {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    var reactor: Reactor { get }
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

// MARK: - Implementation -

extension ReactorView {
    @_optimize(none)
    public var body: Body {
        .init(reactor: reactor, content: makeBody)
    }
}

// MARK: - Auxiliary Implementation -

@_frozen
public struct _SynthesizedReactorViewBody<Reactor: ViewReactor, Content: View>: View {
    private let content: Content
    
    public init(reactor: Reactor, content: (Reactor) -> Content) {
        self.content = content(reactor)
    }
    
    @_optimize(none)
    public var body: some View {
        content
    }
}
