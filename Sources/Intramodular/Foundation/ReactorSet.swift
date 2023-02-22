//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

/// A set of `Reactor`s.
public struct ReactorSet {
    private var value: [ObjectIdentifier: () -> any Reactor] = [:]
    
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
    
    public mutating func insert<R: Reactor>(_ reactor: @escaping () -> R)  {
        value[ObjectIdentifier(R.self)] = reactor
    }
    
    public mutating func insert(_ reactors: ReactorSet) {
        value.merge(reactors.value, uniquingKeysWith: { x, y in x })
    }
    
    @discardableResult
    public func dispatch(_ action: any ReactorAction) -> AnyTask<Void, Error>! {
        let result = value.values.compactMap({ $0()._opaque_dispatch(action) })
        
        if result.isEmpty {
            debugPrint("\(action) was not sufficiently handled.")
        } else if result.count > 1 {
            assertionFailure("\(action) was handled more than once.")
        }
        
        return result.first
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    struct ReactorsKey: SwiftUI.EnvironmentKey {
        static let defaultValue = ReactorSet()
    }
    
    public var reactors: ReactorSet {
        get {
            self[ReactorsKey.self]
        } set {
            self[ReactorsKey.self] = newValue
        }
    }
}

public struct ReactorSetAccessView<Content: View>: View {
    @usableFromInline
    @Environment(\.reactors) var reactors
    
    public var content: (ReactorSet) -> Content
    
    public init(@ViewBuilder content: @escaping (ReactorSet) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(reactors)
    }
}

// MARK: - Usage -

extension View {
    public func onAppear(dispatch action: any ReactorAction) -> some View {
        ReactorSetAccessView { reactors in
            self.onAppear {
                reactors.dispatch(action)
            }
        }
    }
    
    public func onAppear<R: ViewReactor>(dispatch action: R.Action, in reactor: R) -> some View {
        onAppear {
            reactor.dispatch(action)
        }
    }
}
