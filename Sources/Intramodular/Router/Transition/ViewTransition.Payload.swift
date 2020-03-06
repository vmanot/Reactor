//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

extension ViewTransition {
    enum Payload {
        case present(EnvironmentalAnyView)
        case replacePresented(with: EnvironmentalAnyView)
        case dismiss
        case dismissView(named: ViewName)
        
        case push(EnvironmentalAnyView)
        case pushOrPresent(EnvironmentalAnyView)
        case pop
        case popOrDismiss
        
        case set(EnvironmentalAnyView)
        case setNavigatable(EnvironmentalAnyView)
        
        case linear([ViewTransition])
        
        case dynamic(() -> AnyPublisher<ViewTransitionContext, ViewRouterError>)
        
        case none
    }
}

extension ViewTransition.Payload {
    var view: EnvironmentalAnyView? {
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
                case .pushOrPresent(let view):
                    return view
                case .pop:
                    return nil
                case .popOrDismiss:
                    return nil
                case .set(let view):
                    return view
                case .setNavigatable(let view):
                    return view
                case .linear:
                    return nil
                case .dynamic:
                    return nil
                case .none:
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
                case .pushOrPresent:
                    self = .pushOrPresent(newValue)
                case .pop:
                    break
                case .popOrDismiss:
                    break
                case .set:
                    self = .set(newValue)
                case .setNavigatable:
                    self = .setNavigatable(newValue)
                case .linear:
                    break
                case .dynamic:
                    break
                case .none:
                    break
            }
        }
    }
}
