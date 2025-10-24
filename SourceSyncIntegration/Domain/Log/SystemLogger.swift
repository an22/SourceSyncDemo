//
//  StdLogger.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 23.10.2025.
//

import Foundation

class SystemLogger: LoggerImpl {
    
    private let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    func logEvent(_ event: LogEvent) {
        print("\(dateFormatter.string(from: event.date)): \(event.eventName) - \(event.message)")
    }
    
    func logError(_ error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
}
