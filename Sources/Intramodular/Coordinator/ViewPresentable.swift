//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol Presentable: class {
    var environmentObjects: EnvironmentObjects { get set }
    
    var presenter: Presentable? { get }
}

extension Presentable {
    public func appendEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentObjects.append(bindable)
    }
    
    public func appendEnvironmentObjects(_ bindables: EnvironmentObjects) {
        environmentObjects.append(contentsOf: bindables)
    }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIView: Presentable {
    public var presenter: Presentable? {
        return superview
    }
    
    public var environmentObjects: EnvironmentObjects {
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
    
    public var environmentObjects: EnvironmentObjects {
        get {
            .init()
        } set {
            fatalError()
        }
    }
}

#endif
