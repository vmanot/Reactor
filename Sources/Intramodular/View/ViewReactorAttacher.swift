//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

private struct ViewReactorAttacher<Reactor: ViewReactor, Content: View>: View {
    let reactor: () -> Reactor
    let content: Content

    var taskPipeline: TaskPipeline {
        reactor().environment.taskPipelineUnwrapped
    }
    
    var body: some View {
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
        ViewReactorAttacher(reactor: reactor, content: self)
    }
}
