//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension Task {
    /// The output of a task.
    public enum Output {
        case started
        case progress(Progress?)
        case success(Success)
        
        public var isTerminal: Bool {
            switch self {
                case .success:
                    return true
                default:
                    return false
            }
        }
    }
    
    /// The failure of a task.
    public enum Failure: Swift.Error {
        case canceled
        case error(Error)
    }
    
    /// The status of a task.
    public enum Status {
        case idle
        case started
        case progress(Progress?)
        case canceled
        case success(Success)
        case error(Error)
        
        public var isEnded: Bool {
            switch self {
                case .success, .canceled, .error:
                    return true
                default:
                    return false
            }
        }
        
        public init(_ output: Task.Output) {
            switch output {
                case .started:
                    self = .started
                case .progress(let progress):
                    self = .progress(progress)
                case .success(let success):
                    self = .success(success)
            }
        }
        
        public init(_ failure: Task.Failure) {
            switch failure {
                case .canceled:
                    self = .canceled
                case .error(let error):
                    self = .error(error)
            }
        }
    }
}

// MARK: - Protocol Implementations -

extension Task.Output: Equatable where Success: Equatable {
    
}

extension Task.Failure: Equatable where Error: Equatable {
    
}

extension Task.Status: Equatable where Success: Equatable, Error: Equatable {
    
}

extension Task.Output: Hashable where Success: Hashable {
    
}

extension Task.Failure: Hashable where Error: Hashable {
    
}

extension Task.Status: Hashable where Success: Hashable, Error: Hashable {
    
}
