//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension OpaqueTask {
    public enum StatusDescription: Hashable {
        case idle
        case started
        case progress(Progress?)
        case canceled
        case success
        case error(OpaqueError)
    }
}

extension OpaqueTask.StatusDescription {
    public var isActive: Bool {
        switch self {
            case .started, .progress:
                return true
            default:
                return false
        }
    }
    
    public init<Success, Error>(_ status: Task<Success, Error>.Status) {
        switch status {
            case .idle:
                self = .idle
            case .started:
                self = .started
            case .progress(let progress):
                self = .progress(progress)
            case .canceled:
                self = .canceled
            case .success:
                self = .success
            case .error(let error):
                self = .error(.init(error))
        }
    }
}

// MARK: - Auxiliary -

extension OpaqueTask.StatusDescription {
    public struct OpaqueError: Hashable {
        public let localizedDescription: String
        
        fileprivate init(_ error: Error) {
            self.localizedDescription = error.localizedDescription
        }
    }
}

extension OpaqueTask.StatusDescription {
    public enum _Comparison {
        case active
        
        public static func == (
            lhs: OpaqueTask.StatusDescription?,
            rhs: Self
        ) -> Bool {
            if let lhs = lhs {
                switch rhs {
                    case .active:
                        return lhs.isActive
                }
            } else {
                return false
            }
        }
    }
}
