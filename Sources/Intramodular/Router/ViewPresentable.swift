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
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
    }
    
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) {
        environmentBuilder.merge(builder)
    }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private var environmentBuilderKey: Void = ()

extension UIView: Presentable {
    public var presenter: Presentable? {
        return superview
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIViewController: Presentable {
    public var presenter: Presentable? {
        return parent
    }
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            objc_getAssociatedObject(self, &environmentBuilderKey) as? EnvironmentBuilder ?? .init()
        } set {
            objc_setAssociatedObject(self, &environmentBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

#endif
