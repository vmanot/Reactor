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
    
    public var presentedViewName: ViewName? {
        environment.dynamicViewPresenter!.presentedViewName
    }
    
    /// Present a view.
    public func present(_ modal: AnyModalPresentation) {
        environment.dynamicViewPresenter!.present(modal)
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        environment.dynamicViewPresenter!.dismiss(animated: animated, completion: completion)
    }
    
    public func dismissView(
        named name: ViewName,
        completion: @escaping () -> Void
    ) {
        environment.dynamicViewPresenter!.dismissView(named: name, completion: completion)
    }
    
    /// Dismiss the view with the given name.
    public func dismissView(named name: Subview) {
        environment.dynamicViewPresenter!.dismissView(named: name)
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
