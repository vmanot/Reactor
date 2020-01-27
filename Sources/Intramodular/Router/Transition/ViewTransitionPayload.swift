//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

enum ViewTransitionPayload {
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

extension ViewTransitionPayload {
    func transformView(_ transform: (inout AnyPresentationView) -> Void) -> Self {
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
                return .linear(transitions.map({ $0.transformView(transform) }))
            case .dynamic:
                return self
        }
    }
}
