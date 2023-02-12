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
    @inlinable
    public var body: some View {
        _SynthesizedReactorDependentViewBody(content: makeBody)
    }
    
    @inlinable
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .attach(reactor)
    }
}

// MARK: - Auxiliary -

public struct _SynthesizedReactorDependentViewBody<Reactor: ViewReactor, Content: View>: View {
    @usableFromInline
    @EnvironmentReactor var reactor: Reactor
    
    @usableFromInline
    let content: (Reactor) -> Content
    
    public init(content: @escaping (Reactor) -> Content) {
        self.content = content
    }
    
    @inlinable
    public var body: some View {
        content(reactor)
    }
}
