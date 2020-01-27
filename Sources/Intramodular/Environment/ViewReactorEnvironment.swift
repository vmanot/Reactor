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
        let cancellables = Cancellables()
        
        var onReactorInitialization: Actions?
        
        var isReactorInitialized: Bool = false {
            didSet {
                guard isReactorInitialized, oldValue == false else {
                    return
                }
                
                onReactorInitialization?.perform()
            }
        }
    }
    
    let object = Object()
    
    @InjectedReactors() public var injectedReactors
    
    @Environment(\.self) var environment
    @Environment(\.dynamicViewPresenter) var dynamicViewPresenter
    
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
