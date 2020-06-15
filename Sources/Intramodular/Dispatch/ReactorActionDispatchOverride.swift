//
// Copyright (c) Vatsal Manot
//

import Coordinator
import Merge
import SwiftUIX
import Task

public struct ReactorDispatchOverride: Equatable {
    @usableFromInline
    typealias Value = (opaque_ReactorDispatchItem, Task<Void, Error>) -> Task<Void, Error>
    
    @usableFromInline
    let id: UUID
    
    @usableFromInline
    let filter: (opaque_ReactorDispatchItem) -> Bool
    
    @usableFromInline
    let value: Value
    
    @usableFromInline
    func provide<R: Reactor>(for action: R.Action, task: ReactorActionTask<R>) -> ReactorActionTask<R> {
        value(action, task).eraseToActionTask() // FIXME!!
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension ReactorDispatchOverride {
    @usableFromInline
    final class PreferenceKey: ArrayReducePreferenceKey<ReactorDispatchOverride> {
        
    }
}

@usableFromInline
struct _OverrideReactorActionViewModifier: ViewModifier {
    @usableFromInline
    @State var id: UUID = .init()
    
    @usableFromInline
    let filter: (opaque_ReactorDispatchItem) -> Bool
    
    @usableFromInline
    let value: ReactorDispatchOverride.Value
    
    @usableFromInline
    init(
        filter: @escaping (opaque_ReactorDispatchItem) -> Bool,
        value: @escaping ReactorDispatchOverride.Value
    ) {
        self.filter = filter
        self.value = value
    }
    
    @usableFromInline
    func body(content: Content)  -> some View {
        content.preference(
            key: ReactorDispatchOverride.PreferenceKey.self,
            value: [.init(id: id, filter: filter, value: value)]
        )
    }
}

extension View {
    @inlinable
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: Task<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.createTaskName() == action.createTaskName() },
                value: { task.concatenate(with: $1) }
            )
        )
    }
    
    @inlinable
    public func prehook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        prehook(action, perform: MutableTask(action: task))
    }
    
    @inlinable
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: Task<Void, Error>
    ) -> some View {
        modifier(
            _OverrideReactorActionViewModifier(
                filter: { $0.createTaskName() == action.createTaskName() },
                value: { $1.concatenate(with: task) }
            )
        )
    }
    
    @inlinable
    public func posthook<A: ReactorAction>(
        _ action: A,
        perform task: @escaping () -> Void
    ) -> some View {
        posthook(action, perform: MutableTask(action: task))
    }
}
