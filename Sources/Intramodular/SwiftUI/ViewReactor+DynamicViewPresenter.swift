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
        
        var item = item
        
        item.content.mergeEnvironmentBuilderInPlace(coordinator.environmentBuilder)
        
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

extension ReactorActionTask where R: ViewReactor {
    @inlinable
    public static func present<V: View>(_ view: @autoclosure @escaping () throws -> V) -> Self {
        .action({ try $0.withReactor({ $0.present(try view()) }) })
    }
    
    @inlinable
    public static func presentOnTop<V: View>(_ view: @autoclosure @escaping () throws -> V) -> Self {
        .action({ try $0.withReactor({ $0.presentOnTop(try view()) }) })
    }
    
    @inlinable
    public static func dismiss() -> Self {
        .action({ $0.withReactor({ $0.dismiss() }) })
    }
}
