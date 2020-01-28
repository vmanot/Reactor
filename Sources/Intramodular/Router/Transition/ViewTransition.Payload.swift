//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

extension ViewTransition {
    enum Payload {
        case present(AnyPresentationView)
        case replacePresented(with: AnyPresentationView)
        case dismiss
        case dismissView(named: ViewName)
        
        case push(AnyPresentationView)
        case pop
        
        case set(AnyPresentationView)
        
        case linear([ViewTransition])
        
        case dynamic(() -> AnyPublisher<ViewTransitionContext, ViewRouterError>)
    }
}

extension ViewTransition.Payload {
    var view: AnyPresentationView? {
        get {
            switch self {
                case .present(let view):
                    return view
                case .replacePresented(let view):
                    return view
                case .dismiss:
                    return nil
                case .dismissView:
                    return nil
                case .push(let view):
                    return view
                case .pop:
                    return nil
                case .set(let view):
                    return view
                case .linear:
                    return nil
                case .dynamic:
                    return nil
            }
        } set {
            guard let newValue = newValue else {
                return
            }
            
            switch self {
                case .present:
                    self = .present(newValue)
                case .replacePresented:
                    self = .replacePresented(with: newValue)
                case .dismiss:
                    break
                case .dismissView:
                    break
                case .push:
                    self = .push(newValue)
                case .pop:
                    break
                case .set:
                    self = .set(newValue)
                case .linear:
                    break
                case .dynamic:
                    break
            }
        }
    }
    
    func transformViewIfPresent(_ transform: (inout AnyPresentationView) -> Void) -> Self {
        switch self {
            case .present(let view):
                return .present(view.then(transform))
            case .replacePresented(let view):
                return .replacePresented(with: view.then(transform))
            case .dismiss:
                return self
            case .dismissView:
                return self
            case .push(let view):
                return .push(view.then(transform))
            case .pop:
                return self
            case .set(let view):
                return .set(view.then(transform))
            case .linear(let transitions):
                return .linear(transitions.map({ $0.transformViewIfPresent(transform) }))
            case .dynamic:
                return self
        }
    }
}
