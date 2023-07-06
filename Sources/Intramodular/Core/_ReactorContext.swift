//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import SwiftUIX

public final class _ReactorContext: CancellablesHolder, ObservableObject, _ReactorContextProtocol {
    @PublishedObject public var _taskGraph = _ObservableTaskGraph()
    
    public var _actionIntercepts: [_ReactorActionIntercept] = []
    
    public init() {
        
    }
}

private var reactorEnvironmentKey: UInt8 = 0

extension Reactor where Self: ObservableObject, Self.ReactorContext == _ReactorContext {
    public var context: _ReactorContext {
        if let result = objc_getAssociatedObject(self, &reactorEnvironmentKey) as? ReactorContext {
            return result
        } else {
            let result = _ReactorContext()
            
            if let objectWillChangePublisher = self.objectWillChange as? ObservableObjectPublisher {
                result
                    .objectWillChange
                    .publish(to: objectWillChangePublisher)
                    .subscribe(in: result.cancellables)
            }
            
            objc_setAssociatedObject(self, &reactorEnvironmentKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}
