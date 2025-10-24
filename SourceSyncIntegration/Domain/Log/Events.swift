//
//  Events.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 23.10.2025.
//

import SourceSyncCore

class AppInitializationEvents {
    static func start() -> LogEvent {
        return LogEvent(eventName: "AppInitializationStart", message: "Initialization started")
    }
    
    static func result(attempt:Int, error: Error? = nil) -> LogEvent {
        var message = "Initialization Success"
        if let error = error {
            message = "Initialization failed \(error.localizedDescription)"
        }
        return LogEvent(eventName: "AppInitializationResult", message: message + " Attempts: \(attempt)")
    }
    
    static func finish() -> LogEvent {
        return LogEvent(eventName: "AppInitializationEnd", message: "Initialization finished")
    }
}

class ContentInitializationEvents {
    static func start() -> LogEvent {
        return LogEvent(eventName: "ContentInitializationStart", message: "Initialization started")
    }
    
    static func result(error: Error? = nil) -> LogEvent {
        var message = "Content initialization success"
        if let error = error {
            message = "Content initialization failed \(error.localizedDescription)"
        }
        return LogEvent(eventName: "AppInitializationResult", message: message)
    }
    
    static func finish() -> LogEvent {
        return LogEvent(eventName: "ContentInitializationEnd", message: "Initialization finished")
    }
}

class ActivationEvents {
    static func start(currentTime: Int64, timeWindow: Int64) -> LogEvent {
        let message = "Loading started with parameters: currentTime: \(currentTime), timeWindow: \(timeWindow)"
        return LogEvent(eventName: "ActivationLoadingStart", message: message)
    }
    
    static func result(activations: [Activation],error: Error? = nil) -> LogEvent {
        var message = "Activation loading success"
        if let error = error {
            message = "Activation loading failed \(error.localizedDescription)"
        }
        return LogEvent(eventName: "ActivationLoadingResult", message: message)
    }
    
    static func finish(currentTime: Int64, timeWindow: Int64) -> LogEvent {
        return LogEvent(eventName: "ActivationLoadingEnd", message: "Loading finished")
    }
}

class MediaEvents {
    static func playbackMediaReplaced(to: (String, String)) -> LogEvent {
        let message = "Previous media replaced by new media \(to.0) (\(to.1))"
        return LogEvent(eventName: "PlaybackMediaReplaced", message: message)
    }
    
    static func play() -> LogEvent {
        return LogEvent(eventName: "PlaybackResumed", message: "User resumed playback")
    }
    
    static func pause() -> LogEvent {
        return LogEvent(eventName: "PlaybackPaused", message: "User paused playback")
    }
}
