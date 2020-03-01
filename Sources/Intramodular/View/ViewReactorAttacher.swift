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
        if !reactor().environment.isSetup { // FIXME?
            DispatchQueue.main.async {
                self.reactor().environment.$isSetup.wrappedValue = true
                self.reactor().setup()
            }
        }
        
        return content
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
}
