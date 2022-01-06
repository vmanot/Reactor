//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension ViewReactor {
    public var presenter: DynamicViewPresenter? {
        environment.environment.presenter?.presenter
    }
    
    public var presentationName: AnyHashable? {
        environment.environment.presenter?.presentationName
    }

    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        guard let presenter = environment.environment.presenter else {
            assertionFailure()
            
            return .init()
        }
        
        return presenter._cocoaPresentationCoordinator
    }
    
    public var presented: DynamicViewPresentable? {
        environment.environment.presenter?.presented
    }
    
    public func present(_ item: AnyModalPresentation, completion: @escaping () -> Void) {
        guard let presenter = environment.environment.presenter else {
            return assertionFailure()
        }
                        
        presenter.present(item, completion: completion)
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard let presenter = environment.environment.presenter else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return presenter.dismiss(withAnimation: animation)
    }
    
    @discardableResult
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard let presenter = environment.environment.presenter else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return presenter.dismissSelf(withAnimation: animation)
    }
    
    /// Dismisses a given subview.
    @inlinable
    public func dismiss(_ subview: Subview) {
        guard let presenter = environment.environment.presenter else {
            return assertionFailure()
        }
        
        presenter.dismissView(named: subview)
    }
}
