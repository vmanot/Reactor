//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

final public class ReactorDispatchGlobal: ObservableObject {
    public typealias ObjectWillChangePublisher = PassthroughSubject<_opaque_ReactorAction, Never>
    
    public static let shared = ReactorDispatchGlobal()
    
    public let objectWillChange = PassthroughSubject<_opaque_ReactorAction, Never>()
    
    private init() {
        
    }
}

extension ReactorDispatchGlobal {
    public static func send(_ value: _opaque_ReactorAction) {
        DispatchQueue.asyncOnMainIfNecessary {
            shared.objectWillChange.send(value)
        }
    }
    
    public static func message<R: Reactor>(_: R.Type, _ action: R.Action) {
        send(action)
    }
}
