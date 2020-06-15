# Reactor
A state management framework for SwiftUI. 

## Why

Reactor is a Flux-inspired, reactive state management 

```swift
struct ExampleView: ReactorView {
    let reactor: Reactor
    
    init(reactor: Reactor) {
        self.reactor = reactor
    }
    
    func makeBody(reactor: Reactor) -> some View {
        Group {
            if reactor.status(of: .foo) == .active {
                ActivityIndicator()
            } else {
                reactor.taskButton(for: .foo) {
                    Text("Run foo!")
                }
            }
        }
    }
}

extension ExampleView {
    struct Reactor: ViewReactor {
        enum Action: ReactorAction {
            case foo
        }
        
        @ViewReactorEnvironment() var environment
    }
}

extension ExampleView.Reactor {
    func task(for action: Action) -> ActionTask {
        switch action {
            case .foo:
                return Just(())
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                    .eraseToActionTask()
        }
    }
}
```
