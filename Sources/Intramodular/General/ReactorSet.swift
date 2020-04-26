//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

public struct ReactorSet {
    private var value: [ObjectIdentifier: () -> opaque_Reactor] = [:]
    
    public init() {
        
    }
    
    public subscript<R: Reactor>(_ reactorType: R.Type) -> R? {
        get {
            value[ObjectIdentifier(R.self)]?() as? R
        } set {
            if let newValue = newValue {
                value[ObjectIdentifier(R.self)] = { newValue }
            } else {
                value[ObjectIdentifier(R.self)] = nil
            }
        }
    }
}

extension ReactorSet {
    public mutating func insert<R: Reactor>(_ reactor: @escaping () -> R)  {
        value[ObjectIdentifier(R.self)] = reactor
    }
    
    public mutating func insert(_ reactors: ReactorSet) {
        value.merge(reactors.value, uniquingKeysWith: { x, y in x })
    }
}

extension ReactorSet {
    @discardableResult
    public func dispatch(_ action: opaque_ReactorAction) -> Task<Void, Error>! {
        let result = value.values.compactMap({ $0().opaque_dispatch(action) })
        
        if result.isEmpty {
            debugPrint("\(action) was not sufficiently handled.")
        } else if result.count > 1 {
            assertionFailure("\(action) was handled more than once.")
        }
        
        return result.first
    }
}

// MARK: - Auxiliary Implementation -

extension ReactorSet {
    public struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = ReactorSet()
    }
}

extension EnvironmentValues {
    public var viewReactors: ReactorSet {
        get {
            self[ReactorSet.EnvironmentKey.self]
        } set {
            self[ReactorSet.EnvironmentKey.self] = newValue
        }
    }
}

public struct ReactorSetAccessView<Content: View>: View {
    @usableFromInline
    @Environment(\.viewReactors) var viewReactors
    
    public var content: (ReactorSet) -> Content
    
    @inlinable
    public init(@ViewBuilder content: @escaping (ReactorSet) -> Content) {
        self.content = content
    }
    
    @inlinable
    public var body: some View {
        content(viewReactors)
    }
}

// MARK: - Usage -

extension View {
    @inlinable
    public func onAppear(dispatch action: opaque_ReactorAction) -> some View {
        ReactorSetAccessView { reactors in
            self.onAppear {
                reactors.dispatch(action)
            }
        }
    }
    
    @inlinable
    public func onAppear<R: ViewReactor>(dispatch action: R.Action, in reactor: R) -> some View {
        onAppear {
            reactor.dispatch(action)
        }
    }
}
