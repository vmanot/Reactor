//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI

@propertyWrapper
public struct _ReactorContextDynamicProperty<ReactorType: Reactor>: DynamicProperty, _ReactorContextProtocol {
    @Environment(\.self) var environment
    
    @State public private(set) var cancellables = Cancellables()
    @PersistentObject public private(set) var _actionTasks = _ObservableTaskGroup<ReactorType.Action>()
    @State public internal(set) var _actionIntercepts: [_ReactorActionIntercept] = []
    @State var environmentInsertions = EnvironmentInsertions()
    @State var isSetup: Bool = false
    
    public var wrappedValue: Self {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init() {
        
    }
    
    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        guard !isSetup else {
            return
        }
    }
}
