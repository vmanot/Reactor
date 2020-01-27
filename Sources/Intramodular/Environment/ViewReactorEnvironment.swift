//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI
import Task

public struct ViewReactorEnvironment: DynamicProperty {
    final class Object: ObservableObject {
        @Published var cycle: Int = 0
        
        let cancellables = Cancellables()
        
        func update() {
            cycle += 1
        }
    }
    
    let object = Object()
    
    @EnvironmentReactors() public var environmentReactors
    
    @Environment(\.self) var environment
    @Environment(\.dynamicViewPresenter) var dynamicViewPresenter
    
    @OptionalEnvironmentObject var parentTaskPipeline: TaskPipeline?
    @OptionalObservedObject var taskPipeline: TaskPipeline!
    
    public init() {
        taskPipeline = .init(parent: parentTaskPipeline)
    }
}

extension ViewReactorEnvironment {
    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        self.object.update()
        
        if object.cycle == 1 {
            reactor.wrappedValue.router.environmentBuilder.insertEnvironmentReactor(reactor)
            reactor.wrappedValue.setup()
        }
    }
}

// MARK: - API -

@propertyWrapper
public struct ReactorEnvironment: DynamicProperty {
    public private(set) var wrappedValue = ViewReactorEnvironment()
    
    public init() {
        
    }
}

// MARK: - Helpers -

extension EnvironmentBuilder {
    public mutating func insertEnvironmentReactor<R: ViewReactor>(_ reactor: ReactorReference<R>) {
        set({ $0.environmentReactor(reactor.wrappedValue) }, forKey: ObjectIdentifier(R.self))
    }
}
