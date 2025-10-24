//
//  SourceSyncModel.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 24.10.2025.
//

import Foundation

enum SourceSyncInitializationStatus {
    case none
    case success
    case inProgress
    case failed(Error)
}

enum SourceSyncInitializationError: Error {
    case initializationInProgress(String)
    case initializationFailed(String)
}

enum SourceSyncError: LocalizedError {
    case unknown(_ message: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown(message: let message):
            return message
        }
    }
}

enum SourceSyncResult<Value> {
    case success(Value)
    case failure(Error)
    
    func map<T>(_ transform: (Value) -> T) -> SourceSyncResult<T> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}
