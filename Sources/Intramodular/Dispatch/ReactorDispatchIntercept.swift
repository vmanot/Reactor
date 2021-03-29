//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX

public struct ReactorDispatchIntercept: Equatable {
    @usableFromInline
    typealias PreferenceKey = ArrayReducePreferenceKey<ReactorDispatchIntercept>
    @usableFromInline
    typealias Value = (_opaque_ReactorDispatchItem, AnyTask<Void, Error>) -> AnyTask<Void, Error>
    
    @usableFromInline
    let id: UUID
    
    @usableFromInline
    let filter: (_opaque_ReactorDispatchItem) -> Bool
    
    @usableFromInline
    let value: Value
    
    @usableFromInline
    func provide<R: Reactor>(for action: R.Action, task: ReactorActionTask<R>) -> ReactorActionTask<R> {
        value(action, task.eraseToAnyTask()).eraseToActionTask() // FIXME!!
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

@usableFromInline
struct _OverrideReactorActionViewModifier: ViewModifier {
    @usableFromInline
    @State var id: UUID = .init()
    
    @usableFromInline
    let filter: (_opaque_ReactorDispatchItem) -> Bool
    
    @usableFromInline
    let value: ReactorDispatchIntercept.Value
    
    @usableFromInline
    init(
        filter: @escaping (_opaque_ReactorDispatchItem) -> Bool,
        value: @escaping ReactorDispatchIntercept.Value
    ) {
        self.filter = filter
        self.value = value
    }
    
    @usableFromInline
    func body(content: Content)  -> some View {
        content.preference(
            key: ReactorDispatchIntercept.PreferenceKey.self,
            value: [.init(id: id, filter: filter, value: value)]
        )
    }
}

extension View {
    @inlinable
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.createTaskIdentifier() == action.createTaskIdentifier() },
                value: { task.concatenate(with: $1) }
            )
        )
    }
    
    @inlinable
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.createTaskIdentifier() == action.createTaskIdentifier() },
                value: { task().concatenate(with: $1) }
            )
        )
    }
    
    @inlinable
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        prehook(action, perform: PassthroughTask(action: task).eraseToAnyTask())
    }
    
    @inlinable
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.createTaskIdentifier() == action.createTaskIdentifier() },
                value: { $1.concatenate(with: task) }
            )
        )
    }
    
    @inlinable
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> AnyTask<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.createTaskIdentifier() == action.createTaskIdentifier() },
                value: { $1.concatenate(with: task()) }
            )
        )
    }
    
    @inlinable
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        posthook(action, perform: PassthroughTask(action: task).eraseToAnyTask())
    }
}
