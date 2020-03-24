//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor where Self: DynamicViewPresenter {
    public var presenter: DynamicViewPresenter? {
        environment.dynamicViewPresenter!.presenter
    }
    
    public var presented: DynamicViewPresentable? {
        environment.dynamicViewPresenter!.presented
    }
    
    public var name: ViewName? {
        environment.dynamicViewPresenter!.name
    }
    
    /// Present a view.
    public func present(_ modal: AnyModalPresentation) {
        environment.dynamicViewPresenter!.present(modal)
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        environment.dynamicViewPresenter!.dismiss(animated: animated, completion: completion)
    }
}

extension ReactorActionTask where R: ViewReactor {
    public static func present<V: View>(_ view: V) -> Self {
        .action({ $0.withReactor({ $0.present(view) }) })
    }
    
    public static func dismiss() -> Self {
        .action({ $0.withReactor({ $0.dismiss() }) })
    }
}
