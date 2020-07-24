//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI
import Task

@propertyWrapper
public struct ViewReactorEnvironment: DynamicProperty, ReactorEnvironment {
    @usableFromInline
    @Environment(\.self) var environment
    
    @inlinable
    @ObservedObject public internal(set) var taskPipeline: TaskPipeline
    
    @inlinable
    @State public internal(set) var dispatchOverrides: [ReactorDispatchIntercept] = []

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
        guard !isSetup else {
            return
        }
        
        if let router = (reactor.wrappedValue.router as? EnvironmentProvider) {
            router.environmentBuilder.insertReactor(reactor)
        }
    }
}
