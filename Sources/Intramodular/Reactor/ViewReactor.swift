//
// Copyright (c) Vatsal Manot
//

import CombineX
import SwiftUIX

public protocol opaque_ViewReactor {
    func opaque_dispatch(_ action: ViewReactorAction) -> Void?
}

extension opaque_ViewReactor where Self: ViewReactor {
    public func opaque_dispatch(_ action: ViewReactorAction) -> Void? {
        (action as? Action).map(dispatch)
    }
}

public protocol ViewReactor: opaque_ViewReactor, DynamicProperty {
    associatedtype Mutation
    associatedtype Action
    associatedtype Error: Swift.Error = Never
    
    var cancellables: Cancellables { get }
    
    func mutate(action: Action) -> TaskPublisher<Mutation, Error>
    func reduce(mutation: Mutation)
    func dispatch(_ action: Action)
}

public protocol InitiableViewReactor: ViewReactor {
    init()
}

// MARK: - Action -

extension ViewReactor {
    public func dispatch(_ action: Action) {
        let subscriber = TaskSubscriber<Mutation, Error>()
        
        mutate(action: action).receive(subscriber: subscriber)
        
        if let task = subscriber.task {
            let cancellable = AnyCancellable(task)
            
            subscriber.onReceive = { input in
                switch input {
                    case .inactivity:
                        fatalError()
                    case .activity(_):
                        fatalError()
                    case .success(let value):
                        DispatchQueue.main.async {
                            self.reduce(mutation: value)
                    }
                }
            }
            
            subscriber.onComplete = { [weak cancellables] completion in
                cancellables?.remove(cancellable)
                
                switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        fatalError()
                }
            }
            
            cancellables.insert(cancellable)
            
            task.start()
        }
    }
}
