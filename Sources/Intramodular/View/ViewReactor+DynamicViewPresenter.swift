//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor where Self: DynamicViewPresenter {
    @inlinable
    public var presenter: DynamicViewPresenter? {
        environment.dynamicViewPresenter!.presenter
    }
    
    @inlinable
    public var presented: DynamicViewPresentable? {
        environment.dynamicViewPresenter!.presented
    }
    
    @inlinable
    public var name: ViewName? {
        environment.dynamicViewPresenter!.name
    }
    
    /// Present a view.
    @inlinable
    public func present(_ modal: AnyModalPresentation) {
        environment.dynamicViewPresenter!.present(modal)
    }
    
    /// Dismiss the view owned by `self`.
    @inlinable
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        environment.dynamicViewPresenter!.dismiss(animated: animated, completion: completion)
    }
}

extension ReactorActionTask where R: ViewReactor {
    @inlinable
    public static func present<V: View>(_ view: V) -> Self {
        .action({ $0.withReactor({ $0.present(view) }) })
    }
    
    @inlinable
    public static func dismiss() -> Self {
        .action({ $0.withReactor({ $0.dismiss() }) })
    }
}
