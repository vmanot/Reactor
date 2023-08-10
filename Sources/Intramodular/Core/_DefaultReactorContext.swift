//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Runtime
import SwiftUIX

public final class _DefaultReactorContext<R: Reactor>: ObservableObject, _ReactorContextProtocol {
    public typealias ReactorType = R
    
    @PublishedObject public var _actionTasks = _ObservableTaskGroup<R.Action>()
    
    public var _actionIntercepts: [_ReactorActionIntercept] = []
    
    public init() {
        
    }
}

private let _Reactor_reactorContext = ObjCAssociationKey<any _ReactorContextProtocol>()

extension Reactor where Self: ObservableObject, Self.ReactorContext == _DefaultReactorContext<Self> {
    @MainActor
    public var context: Self.ReactorContext {
        let associatedObjects = ObjCAssociatedObjectView(base: self)
        
        let _result: any _ReactorContextProtocol = associatedObjects[_Reactor_reactorContext, default: { () -> Self.ReactorContext in
            let context = ReactorContext()
            
            if let objectWillChangePublisher = self.objectWillChange as? ObservableObjectPublisher {
                context
                    .objectWillChange
                    .publish(to: objectWillChangePublisher)
                    .subscribe(in: context.cancellables)
            }
            
            return context
        }()]

        return _result as! ReactorContext
    }
}
