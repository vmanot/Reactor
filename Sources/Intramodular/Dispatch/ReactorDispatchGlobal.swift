//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

final public class ReactorDispatchGlobal: ObservableObject {
    public static let shared = ReactorDispatchGlobal()
    
    private let _objectWillChange = PassthroughSubject<opaque_ReactorAction, Error>()
    
    public var objectWillChange: some Publisher {
        _objectWillChange
    }
    
    private init() {
        
    }
}

extension ReactorDispatchGlobal {
    public static func send(_ value: opaque_ReactorAction) {
        shared._objectWillChange.send(value)
    }
}
