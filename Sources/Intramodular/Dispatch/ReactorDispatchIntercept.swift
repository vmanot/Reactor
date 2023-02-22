//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

public struct ReactorDispatchIntercept: Equatable {
    typealias PreferenceKey = ArrayReducePreferenceKey<ReactorDispatchIntercept>
    typealias Value = (any ReactorDispatchable, AnyTask<Void, Error>) -> AnyTask<Void, Error>
    
    let id: UUID
    let filter: (any ReactorDispatchable) -> Bool
    let value: Value
    
    func provide<R: Reactor>(for action: R.Action, task: ReactorActionTask<R>) -> ReactorActionTask<R> {
        value(action, task.eraseToAnyTask()).eraseToActionTask() // FIXME!!
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct _OverrideReactorActionViewModifier: ViewModifier {
    @State var id: UUID = .init()
    let filter: (any ReactorDispatchable) -> Bool
    let value: ReactorDispatchIntercept.Value
    
    init(
        filter: @escaping (any ReactorDispatchable) -> Bool,
        value: @escaping ReactorDispatchIntercept.Value
    ) {
        self.filter = filter
        self.value = value
    }
    
    func body(content: Content)  -> some View {
        content.preference(
            key: ReactorDispatchIntercept.PreferenceKey.self,
            value: [.init(id: id, filter: filter, value: value)]
        )
    }
}

extension View {
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { task.concatenate(with: $1) }
            )
        )
    }
    
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { task().concatenate(with: $1) }
            )
        )
    }
    
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        prehook(action, perform: PassthroughTask(action: task).eraseToAnyTask())
    }
    
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { $1.concatenate(with: task) }
            )
        )
    }
    
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { $1.concatenate(with: task()) }
            )
        )
    }
    
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        posthook(action, perform: PassthroughTask(action: task).eraseToAnyTask())
    }
}

extension ReactorObject {
    public func prehook(
        _ action: Action,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) {
        environment.dispatchIntercepts.append(
            .init(
                id: UUID(),
                filter: { ($0 as? Action) == action },
                value: { task().concatenate(with: $1) }
            )
        )
    }
    
    public func prehook(
        _ action: Action,
        perform task: @escaping () -> Void
    ) {
        prehook(action, perform: { PassthroughTask(action: task).eraseToAnyTask() })
    }
}
