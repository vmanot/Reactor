//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension ViewReactor where Self: DynamicViewPresentable {
    @inlinable
    public var presenter: DynamicViewPresenter? {
        environment.environment.presenter?.presenter
    }
    
    @inlinable
    public var presentationName: ViewName? {
        environment.environment.presenter?.presentationName
    }
}

extension ViewReactor where Self: DynamicViewPresenter {
    @inlinable
    public var presented: DynamicViewPresentable? {
        environment.environment.presenter?.presented
    }
    
    @inlinable
    public func present(_ item: AnyModalPresentation) {
        guard let presenter = environment.environment.presenter else {
            return assertionFailure()
        }
        
        presenter.present(item.mergeEnvironmentBuilder(coordinator.environmentBuilder))
    }
    
    @discardableResult
    @inlinable
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard let presenter = environment.environment.presenter else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return presenter.dismiss(withAnimation: animation)
    }
    
    @discardableResult
    @inlinable
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

extension ReactorActionTask where R: ViewReactor {
    @inlinable
    public static func present<V: View>(_ view: V) -> Self {
        .action({ $0.withReactor({ $0.present(view) }) })
    }
    
    @inlinable
    public static func presentOnTop<V: View>(_ view: V) -> Self {
        .action({ $0.withReactor({ $0.presentOnTop(view) }) })
    }
    
    @inlinable
    public static func dismiss() -> Self {
        .action({ $0.withReactor({ $0.dismiss() }) })
    }
}
