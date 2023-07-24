//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI

@propertyWrapper
public struct _ReactorContextDynamicProperty: DynamicProperty, _ReactorContextProtocol {
    @usableFromInline
    @Environment(\.self) var environment
    @inlinable
    @ObservedObject public internal(set) var _taskGraph: _ObservableTaskGraph<AnyHashable>
    @inlinable
    @State public internal(set) var _actionIntercepts: [_ReactorActionIntercept] = []
    @usableFromInline
    @State var environmentInsertions = EnvironmentInsertions()
    @usableFromInline
    @State var isSetup: Bool = false
    
    public var wrappedValue: Self {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init() {
        _taskGraph = .init()
    }

    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        guard !isSetup else {
            return
        }
    }
}
