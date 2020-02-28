//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI
import Task

@propertyWrapper
public struct ViewReactorEnvironment: ViewReactorComponent {
    final class Object: ObservableObject {
        @Published var cycle: Int = 0
    }
    
    @State var object = Object()
    
    @Environment(\.viewReactors) public var environmentReactors
    @Environment(\.dynamicViewPresenter) var dynamicViewPresenter
    
    @OptionalEnvironmentObject var parentTaskPipeline: TaskPipeline?
    @OptionalObservedObject var taskPipeline: TaskPipeline?
    
    var taskPipelineUnwrapped: TaskPipeline {
        taskPipeline!
    }
    
    public var wrappedValue: Self {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init(wrappedValue: Self = .init()) {
        self.wrappedValue = wrappedValue
    }
    
    public init() {
        taskPipeline = .init(parent: parentTaskPipeline)
    }
}

extension ViewReactorEnvironment {
    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        object.cycle += 1
        
        if object.cycle == 1 {
            reactor.wrappedValue
                .router
                .environmentBuilder
                .insertEnvironmentReactor(reactor)
            
            reactor.wrappedValue.setup()
        }
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentBuilder {
    public mutating func insertEnvironmentReactor<R: ViewReactor>(
        _ reactor: ReactorReference<R>
    ) {
        transformEnvironment({
            $0.viewReactors.insert({ reactor.wrappedValue })
        })
    }
}
