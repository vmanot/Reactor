//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

final public class _ReactorRuntime: ObservableObject {
    public typealias ObjectWillChangePublisher = PassthroughSubject<any Hashable, Never>
    
    public static let shared = _ReactorRuntime()
    
    public let objectWillChange = PassthroughSubject<any Hashable, Never>()
    
    private init() {
        
    }
}

extension _ReactorRuntime {
    public static func send(_ value: any Hashable) {
        DispatchQueue.asyncOnMainIfNecessary {
            shared.objectWillChange.send(value)
        }
    }
    
    public static func message<R: Reactor>(_: R.Type, _ action: R.Action) {
        send(action)
    }
}
