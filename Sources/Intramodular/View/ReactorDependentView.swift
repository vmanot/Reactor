//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import SwiftUI

public protocol ReactorDependentView: View {
    associatedtype Reactor: ViewReactor
    associatedtype ReactorViewBody: View
    
    func makeBody(reactor: Reactor) -> ReactorViewBody
}

// MARK: - API -

extension ReactorDependentView {
    @_optimize(none)
    public var body: some View {
        _SynthesizedReactorDependentViewBody(content: makeBody)
    }
    
    @_optimize(none)
    public func instantiate(from reactor: Reactor) -> some View {
        _SynthesizedReactorViewBody(reactor: reactor, content: makeBody)
    }
}

// MARK: - Auxiliary Implementation -

@_frozen
public struct _SynthesizedReactorDependentViewBody<Reactor: ViewReactor, Content: View>: View {
    @EnvironmentReactor private var reactor: Reactor
    
    private let content: (Reactor) -> Content
    
    public init(content: @escaping (Reactor) -> Content) {
        self.content = content
    }
    
    @_optimize(none)
    public var body: some View {
        content(reactor)
    }
}
