//
// Copyright (c) Vatsal Manot
//

import Combine
import Merge
import SwiftUIX
import SwiftUI
import Task

@propertyWrapper
public struct ViewReactorEnvironment: ReactorEnvironment, ViewReactorComponent {
    @Environment(\.viewReactors) public var environmentReactors
    @Environment(\.dynamicViewPresenter) var dynamicViewPresenter
    
    @ObservedObject var taskPipeline: TaskPipeline
    
    @State var isSetup: Bool = false
    
    @State var isAlertPresented: Bool = false
    @State var alert: Alert? = nil
    
    public var wrappedValue: Self {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init() {
        taskPipeline = .init()
    }
}

extension ViewReactorEnvironment {
    func update<R: ViewReactor>(reactor: ReactorReference<R>) {
        if !isSetup {
            reactor.wrappedValue
                .router
                .environmentBuilder
                .insertEnvironmentReactor(reactor)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentBuilder {
    public mutating func insertEnvironmentReactor<R: ViewReactor>(
        _ reactor: ReactorReference<R>
    ) {
        transformEnvironment({
            $0.viewReactors.insert({ reactor.wrappedValue })
        })
    }
}

extension Alert {
    static let dummy = Alert(
        title: Text("Uh oh!"),
        message: Text("Something went wrong."),
        dismissButton: .destructive(Text("Dismiss"))
    )
}
