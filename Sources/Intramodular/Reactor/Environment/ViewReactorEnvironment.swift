//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI

public struct ViewReactorEnvironment: DynamicProperty {
    final class Object: ObservableObject {
        let cancellables = Cancellables()
    }
    
    let object = Object()
    
    @Reactors() public var injectedReactors
    
    @Environment(\.self) var environment
    @Environment(\.dynamicViewPresenter) public var dynamicViewPresenter
    
    @OptionalEnvironmentObject var parentTaskPipeline: TaskPipeline?
    @OptionalObservedObject var taskPipeline: TaskPipeline!
    
    public init() {
        taskPipeline = .init(parent: parentTaskPipeline)
    }
}

// MARK: - API -

@propertyWrapper
public struct ReactorEnvironment: DynamicProperty {
    public private(set) var wrappedValue = ViewReactorEnvironment()
    
    public init() {
        
    }
}
