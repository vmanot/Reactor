//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public protocol DependentViewReactor: ViewReactor {
    associatedtype Parent: ViewReactor
    
    var parent: Parent { get }
}
