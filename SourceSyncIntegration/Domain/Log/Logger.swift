//
//  Logger.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 23.10.2025.
//

import Foundation

struct LogEvent {
    let eventName: String
    let message: String
    let date: Date = Date()
}

protocol LoggerImpl {
    func logEvent(_ event: LogEvent)
    func logError(_ error: Error)
}

final class Logger: LoggerImpl {
    
    static let shared = Logger()
    private var impl: LoggerImpl = SystemLogger()
    
    private init() {}
    
    /**
     Replaces current logger implementation class
     */
    func setActiveLogger(_ impl: LoggerImpl) {
        self.impl = impl
    }
    
    func logEvent(_ event: LogEvent) {
        impl.logEvent(event)
    }
    
    func logError(_ error: any Error) {
        impl.logError(error)
    }
}
