//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

final public class ReactorDispatchGlobal: ObservableObject {
    public typealias ObjectWillChangePublisher = PassthroughSubject<opaque_ReactorAction, Never>
    
    public static let shared = ReactorDispatchGlobal()
    
    public let objectWillChange = PassthroughSubject<opaque_ReactorAction, Never>()
    
    private init() {
        
    }
}

extension ReactorDispatchGlobal {
    public static func send(_ value: opaque_ReactorAction) {
        DispatchQueue.asyncOnMainIfNecessary {
            shared.objectWillChange.send(value)
        }
    }
}
