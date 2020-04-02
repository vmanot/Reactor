//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

final public class ReactorDispatchGlobal: ObservableObject {
    public static let shared = ReactorDispatchGlobal()
    
    public let objectWillChange = PassthroughSubject<opaque_ReactorAction, Error>()
    
    private init() {
        
    }
}

extension ReactorDispatchGlobal {
    public class func send(_ input: opaque_ReactorAction) {
        shared.objectWillChange.send(input)
    }
}
