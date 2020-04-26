//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public protocol ViewTransitionContext {
    var animation: ViewTransitionAnimation { get }
    var view: EnvironmentalAnyView? { get }
}
