//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI
import Task

@propertyWrapper
public struct ViewReactorEnvironment: ReactorEnvironment, ViewReactorComponent {
    @Environment(\.viewReactors) var viewReactors
    @Environment(\.dynamicViewPresenter) var dynamicViewPresenter
    
    @usableFromInline
    @ObservedObject var taskPipeline: TaskPipeline
    
    @usableFromInline
    @State var environmentBuilder = EnvironmentBuilder()
    
    @usableFromInline
    @State var isSetup: Bool = false
    
    public var wrappedValue: Self {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init() {
        taskPipeline = .init()
    }
}

extension ViewReactorEnvironment {
    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        if !isSetup {
            reactor.wrappedValue
                .router
                .environmentBuilder
                .insertEnvironmentReactor(reactor)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentBuilder {
    public mutating func insertEnvironmentReactor<R: ViewReactor>(
        _ reactor: ReactorReference<R>
    ) {
        transformEnvironment({ $0.viewReactors.insert({ reactor.wrappedValue }) })
    }
}
