//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

extension UIViewController {
    public func trigger(
        _ transition: ViewTransition,
        animated: Bool,
        completion: @escaping () -> ()
    ) throws {
        switch transition {
            case .present(let view): do {
                presentOnTop(view, animated: animated) {
                    completion()
                }
            }
            
            case .replacePresented(let view): do {
                if presentedViewController != nil {
                    dismiss { // FIXME: Does not respect `animated`!
                        self.presentOnTop(view, animated: animated) {
                            completion()
                        }
                    }
                } else {
                    self.presentOnTop(view, animated: animated) {
                        completion()
                    }
                }
            }
            
            case .dismiss: do {
                guard presentedViewController != nil else {
                    throw ViewRouterError.transitionError(.nothingToDismiss)
                }
                
                dismiss(animated: animated) {
                    completion()
                }
            }
            
            case .push(let view): do {
                guard let viewController = self as? UINavigationController else {
                    throw ViewRouterError.transitionError(.notANavigationController)
                }
                
                viewController.pushViewController(CocoaHostingController(rootView: view), animated: animated) {
                    completion()
                }
            }
            
            case .pop: do {
                guard let viewController = self as? UINavigationController else {
                    throw ViewRouterError.transitionError(.notANavigationController)
                }
                
                viewController.popViewController(animated: animated) {
                    completion()
                }
            }
            
            case .set(let view): do {
                if topMostPresentedViewController != nil {
                    dismiss { // FIXME: Does not respect `animated`!
                        self.presentOnTop(view, animated: true) {
                            completion()
                        }
                    }
                } else if let viewController = self as? UINavigationController {
                    viewController.setViewControllers([CocoaHostingController(rootView: view)], animated: animated)
                    
                    completion()
                } else if let window = self.view.window, window.rootViewController === self {
                    window.rootViewController = CocoaHostingController(rootView: view)
                    
                    completion()
                }
            }
            
            case .none: do {
                completion()
            }
            
            case .linear(var transitions): do {
                guard !transitions.isEmpty else {
                    return completion()
                }
                
                var _error: Error?
                
                try trigger(transitions.removeFirst(), animated: animated) {
                    do {
                        try self.trigger(.linear(transitions), animated: animated) {
                            completion()
                        }
                    } catch {
                        _error = error
                    }
                }
                
                if let error = _error {
                    throw error
                }
            }
            
            case .dynamic: do {
                fatalError()
            }
        }
    }
        
    public func presentOnTop<V: View>(
        _ view: V,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        topMostViewController.present(
            view,
            onDismiss: nil,
            style: .automatic,
            completion: completion
        )
    }
}
