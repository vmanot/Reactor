//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor {
    public var environmentReactors: ViewReactors {
        environment.environmentReactors
    }
}

extension ViewReactor where Self: DynamicViewPresenter {
    public var presenting: DynamicViewPresenter? {
        environment.dynamicViewPresenter!.presenting
    }
    
    public var presented: DynamicViewPresenter? {
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

extension ViewReactor {
    public func activeTaskID(of action: Action) -> some Hashable {
        environment
            .taskPipelineUnwrapped[action.createTaskName()]?
            .id
    }
    
    public func status(of action: Action) -> OpaqueTask.StatusDescription? {
        environment
            .taskPipelineUnwrapped[action.createTaskName()]?
            .statusDescription
    }
    
    public func lastStatus(of action: Action) -> OpaqueTask.StatusDescription? {
        environment.taskPipelineUnwrapped.lastStatus(for: action.createTaskName())
    }
    
    public func cancel(action: Action) {
        environment.taskPipelineUnwrapped[action.createTaskName()]?.cancel()
    }
    
    public func cancelAllTasks() {
        environment.taskPipelineUnwrapped.cancelAllTasks()
    }
}
