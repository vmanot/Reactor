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
