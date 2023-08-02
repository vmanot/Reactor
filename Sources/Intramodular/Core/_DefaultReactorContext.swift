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

extension Reactor where Self: ObservableObject, Self.ReactorContext == _DefaultReactorContext<Self> {
    public static var _reactorContextKey: ObjCAssociationKey<Self.ReactorContext> {
        .init()
    }
    
    @MainActor
    public var context: Self.ReactorContext {
        let associatedObjects = ObjCAssociatedObjectView(base: self)
        
        return associatedObjects[Self._reactorContextKey, default: { () -> Self.ReactorContext in
            let context = _DefaultReactorContext<Self>()
            
            if let objectWillChangePublisher = self.objectWillChange as? ObservableObjectPublisher {
                context
                    .objectWillChange
                    .publish(to: objectWillChangePublisher)
                    .subscribe(in: context.cancellables)
            }
            
            return context
        }()]
    }
}
