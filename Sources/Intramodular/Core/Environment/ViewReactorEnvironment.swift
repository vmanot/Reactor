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
    }
    
    @State var object = Object()
    @State var cancellables = Cancellables()
    
    @EnvironmentReactors() public var environmentReactors
    
    @Environment(\.self) var environment
    @Environment(\.dynamicViewPresenter) var dynamicViewPresenter
    
    @OptionalEnvironmentObject var parentTaskPipeline: TaskPipeline?
    @OptionalObservedObject var taskPipeline: TaskPipeline!
    
    var taskPipelineUnwrapped: TaskPipeline {
        taskPipeline!
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

// MARK: - API -

@propertyWrapper
public struct ReactorEnvironment: DynamicProperty {
    public var wrappedValue = ViewReactorEnvironment()
    
    public init() {
        
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
