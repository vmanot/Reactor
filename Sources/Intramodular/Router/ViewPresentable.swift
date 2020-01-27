//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol Presentable: class {
    var environmentBuilder: EnvironmentBuilder { get set }
    
    var presenter: Presentable? { get }
}

extension Presentable {
    public func appendEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
    }
    
    public func appendEnvironmentBuilder(_ bindables: EnvironmentBuilder) {
        environmentBuilder.merge(bindables)
    }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIView: Presentable {
    public var presenter: Presentable? {
        return superview
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            .init()
        } set {
            fatalError()
        }
    }
}

extension UIViewController: Presentable {
    public var presenter: Presentable? {
        return parent
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            .init()
        } set {
            fatalError()
        }
    }
}

#endif
