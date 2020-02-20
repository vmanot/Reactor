//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

private struct ViewReactorAttacher<Reactor: ViewReactor>: ViewModifier {
    let reactor: () -> Reactor
    
    var taskPipeline: TaskPipeline {
        reactor().environment.taskPipelineUnwrapped
    }
    
    func body(content: Content) -> some View {
        content
            .environmentReactor(self.reactor())
            .environment(\.taskPipeline, taskPipeline)
            .environmentObject(taskPipeline)
    }
}

private struct IndirectViewReactorAttacher<Reactor: ViewReactor>: ViewModifier {
    let reactor: () -> Reactor
    
    var taskPipeline: TaskPipeline {
        reactor().environment.taskPipelineUnwrapped
    }
    
    func body(content: Content) -> some View {
        content
            .environmentObject(self.reactor().environment.object)
            .environmentReactor(self.reactor())
            .environment(\.taskPipeline, taskPipeline)
            .environmentObject(taskPipeline)
    }
}

// MARK: - API -

extension View {
    public func attach<R: ViewReactor>(
        _ reactor: @autoclosure @escaping () -> R
    ) -> some View {
        modifier(ViewReactorAttacher(reactor: reactor))
    }
    
    public func attach<R: ViewReactor>(
        indirect reactor: @autoclosure @escaping () -> R
    ) -> some View {
        modifier(IndirectViewReactorAttacher(reactor: reactor))
    }
}
