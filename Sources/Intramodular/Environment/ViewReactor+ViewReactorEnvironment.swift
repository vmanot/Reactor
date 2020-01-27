//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor {
    public var cancellables: Cancellables {
        environment.object.cancellables
    }
    
    public var environmentReactors: ViewReactors {
        environment.environmentReactors
    }
}

extension ViewReactor where Self: DynamicViewPresenter {
    public var isPresented: Bool {
        environment.dynamicViewPresenter?.isPresented ?? false
    }
    
    /// Present a view.
    public func present<V: View>(
        _ view: V,
        named viewName: ViewName? = nil,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle = .automatic,
        completion: (() -> Void)? = nil
    ) {
        environment.dynamicViewPresenter?.present(
            view.attach(self),
            named: viewName,
            onDismiss: onDismiss,
            style: style,
            completion: completion
        )
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss(completion: (() -> Void)?) {
        environment.dynamicViewPresenter?.dismiss(completion: completion)
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss() {
        environment.dynamicViewPresenter?.dismiss()
    }
    
    /// Dismiss the view with the given name.
    public func dismissView(named name: Subview) {
        environment.dynamicViewPresenter?.dismissView(named: name)
    }
}

extension ViewReactor {
    public func status(of action: Action) -> OpaqueTask.StatusDescription? {
        environment.taskPipeline[.init(action)]?.statusDescription
    }
}
