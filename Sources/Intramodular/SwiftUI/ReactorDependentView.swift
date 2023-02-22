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

// MARK: - API

extension ReactorDependentView {
    public var body: some View {
        _SynthesizedReactorDependentViewBody(content: makeBody)
    }
    
    public func instantiate(from reactor: Reactor) -> some View {
        makeBody(reactor: reactor)
            .attach(reactor: reactor)
    }
}

// MARK: - Auxiliary

struct _SynthesizedReactorDependentViewBody<Reactor: ViewReactor, Content: View>: View {
    @EnvironmentReactor var reactor: Reactor
    
    let content: (Reactor) -> Content
    
    init(content: @escaping (Reactor) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(reactor)
    }
}
