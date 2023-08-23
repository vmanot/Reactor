//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

public struct _ReactorActionIntercept: Equatable {
    typealias PreferenceKey = ArrayReducePreferenceKey<_ReactorActionIntercept>
    typealias Value = (any Hashable, AnyTask<Void, Error>) -> AnyTask<Void, Error>
    
    let id: UUID
    let filter: (any Hashable) -> Bool
    let value: Value
    
    func provide<R: Reactor>(for action: R.Action, task: ReactorActionTask<R>) -> ReactorActionTask<R> {
        value(action, task.eraseToAnyTask()).eraseToActionTask() // FIXME!!
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct _OverrideHashableViewModifier: ViewModifier {
    @State var id: UUID = .init()
    let filter: (any Hashable) -> Bool
    let value: _ReactorActionIntercept.Value
    
    init(
        filter: @escaping (any Hashable) -> Bool,
        value: @escaping _ReactorActionIntercept.Value
    ) {
        self.filter = filter
        self.value = value
    }
    
    func body(content: Content)  -> some View {
        content.preference(
            key: _ReactorActionIntercept.PreferenceKey.self,
            value: [.init(id: id, filter: filter, value: value)]
        )
    }
}

@MainActor
extension View {
    public func prehook<A: Hashable>(
        _ action: A,
        perform task: AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideHashableViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { task.concatenate(with: $1) }
            )
        )
    }
    
    public func prehook<A: Hashable>(
        _ action: A,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideHashableViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { task().concatenate(with: $1) }
            )
        )
    }
    
    public func prehook<A: Hashable>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        prehook(action, perform: PassthroughTask(action: task).eraseToAnyTask())
    }
    
    public func posthook<A: Hashable>(
        _ action: A,
        perform task: AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideHashableViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { $1.concatenate(with: task) }
            )
        )
    }
    
    public func posthook<A: Hashable>(
        _ action: A,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideHashableViewModifier(
                filter: { $0.eraseToAnyHashable() == action.eraseToAnyHashable() },
                value: { $1.concatenate(with: task()) }
            )
        )
    }
    
    public func posthook<A: Hashable>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        posthook(action, perform: PassthroughTask(action: task).eraseToAnyTask())
    }
}

@MainActor
extension Reactor where ReactorContext == _ReactorContextDynamicProperty<Self> {
    public func prehook(
        _ action: Action,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) {
        context._actionIntercepts.append(
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
