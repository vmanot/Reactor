//
// Copyright (c) Vatsal Manot
//

import CombineX
import SwiftUIX

public protocol opaque_ViewReactor {
    func opaque_dispatch(_ action: ViewReactorAction) -> Task<Void, Error>?
}

extension opaque_ViewReactor where Self: ViewReactor {
    public func opaque_dispatch(_ action: ViewReactorAction) -> Task<Void, Error>? {
        (action as? Action).map(dispatch)
    }
}

public protocol ViewReactor: opaque_ViewReactor, DynamicProperty {
    associatedtype Action
    associatedtype Event
    
    typealias ActionTaskPublisher = ViewReactorTaskPublisher<Self>
    
    var cancellables: Cancellables { get }
    
    func task(action: Action) -> ActionTaskPublisher
    func reduce(event: Event)
    
    func dispatcher(for action: Action) -> ViewReactorActionDispatcher<Self>
    @discardableResult
    func dispatch(_ action: Action) -> Task<Void, Error>
}

public protocol InitiableViewReactor: ViewReactor {
    init()
}

// MARK: - Implementation -

extension ViewReactor {
    public func dispatcher(for action: Action) -> ViewReactorActionDispatcher<Self> {
        ViewReactorActionDispatcher(reactor: self, action: action)
    }
    
    @discardableResult
    public func dispatch(_ action: Action) -> Task<Void, Error> {
        dispatcher(for: action).dispatch()
    }
}
