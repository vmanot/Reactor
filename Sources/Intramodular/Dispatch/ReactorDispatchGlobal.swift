//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class ReactorDispatchGlobal: ObservableObject {
    public static let shared = ReactorDispatchGlobal()
    
    public let objectWillChange = PassthroughSubject<opaque_ReactorAction, Error>()
    
    private init() {
        
    }
}
