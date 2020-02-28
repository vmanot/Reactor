# Reactor
A state management framework for SwiftUI.

```swift
public struct ExampleView: ReactorView {
    public let reactor: Reactor
    
    public init(reactor: Reactor) {
        self.reactor = reactor
    }
    
    public func makeBody(reactor: Reactor) -> some View {
        Text("Hello world!")
    }
}

extension ExampleView {
    public struct Reactor: ViewReactor {
        public enum Action: ReactorAction {
            
        }
        
        @ViewReactorEnvironment() public var environment
    }
}

extension ExampleView.Reactor {
    public func task(for action: Action) -> ActionTask {
        
    }
}
```
