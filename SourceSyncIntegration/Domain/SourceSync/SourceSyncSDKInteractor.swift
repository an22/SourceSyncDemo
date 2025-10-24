//
//  SourceSyncSDKInteractor.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//

import SourceSyncCore


class SourceSyncSDKInteractor {
    
    static let shared = SourceSyncSDKInteractor()
    
    private init() {}
    
    private var initStatus: SourceSyncInitializationStatus = SourceSyncInitializationStatus.none
    private var application: PlatformApp!
    
    /**
     This methid tries to initialize SourceSync application and retry in a case of failure
     
     - Parameters:
        - depth: current retry depth (you shouldn't manually set this value)
     - Returns `SourceSyncInitializationStatus`
    */
    @MainActor
    func initialize(depth: Int = 0) async -> SourceSyncInitializationStatus {
        if case .inProgress = initStatus {
            return initStatus
        }
        if case .success = initStatus {
            return initStatus
        }
        Logger.shared.logEvent(AppInitializationEvents.start())
        initStatus = .inProgress
        let config = DefaultPlatformAppConfig(
            env: EnvType.dev,
            tenant: nil
        )
        
        do {
            application = try await PlatformAppFactory().create(
                appKey: SourceSyncConstants.appKey,
                config: config
            )
            initStatus = .success
            Logger.shared.logEvent(AppInitializationEvents.result(attempt: depth))
        } catch(let error) {
            initStatus = .failed(error)
            Logger.shared.logEvent(AppInitializationEvents.result(attempt: depth, error: error))
            if (depth < SourceSyncConstants.initAttemptsCount) {
                return await initialize(depth: depth + 1)
            }
        }
        Logger.shared.logEvent(AppInitializationEvents.finish())
        return initStatus
    }
    
    @MainActor
    func initContent(mediaId: String) async -> SourceSyncResult<Content> {
        var result: SourceSyncResult<Content>!
        do {
            Logger.shared.logEvent(ContentInitializationEvents.start())
            try await ensureInitialized()
            let contentConfig = GetContentConfig(
                mediaId: mediaId,
                mediaUrlHash: nil,
                mediaUrl: nil,
                extMediaId: nil,
                distribution: DistributionIdentifier(id: nil, clientId: SourceSyncConstants.clientId),
                production: nil,
                environment: nil,
                dataTrackClient: nil,
                plugins: NSMutableArray(),
                resolveActivations: true,
                effectsSources: NSMutableArray()
            )
            
            let content = try await ContentFactory().create(
                app: application,
                config: contentConfig,
                type: "Mobile",
                os: "iOS",
                city: "New York"
            )
            Logger.shared.logEvent(ContentInitializationEvents.result())
            result = SourceSyncResult.success(content)
        } catch(let error) {
            Logger.shared.logEvent(ContentInitializationEvents.result(error: error))
            result = SourceSyncResult.failure(error)
        }
        Logger.shared.logEvent(ContentInitializationEvents.finish())
        return result
    }
    
    @MainActor
    func fetchActivations(content: Content, currentTimeMs: Int64, timeWindowMs: Int64) async -> SourceSyncResult<[Activation]> {
        var result: SourceSyncResult<[Activation]>!
        do {
            Logger.shared.logEvent(ActivationEvents.start(currentTime: currentTimeMs, timeWindow: timeWindowMs))
            try await ensureInitialized()
            let activations = try await content.getActivations(start: currentTimeMs, duration: timeWindowMs)
            Logger.shared.logEvent(ActivationEvents.result(activations: activations))
            result = SourceSyncResult.success(activations)
        } catch(let error) {
            Logger.shared.logEvent(ActivationEvents.result(activations:[], error: error))
            result = SourceSyncResult.failure(error)
        }
        Logger.shared.logEvent(ActivationEvents.finish(currentTime: currentTimeMs, timeWindow: timeWindowMs))
        return result
    }
    
    
    func ensureInitialized() async throws {
        switch initStatus {
        case .none:
            initStatus = await initialize()
            try await ensureInitialized()
        case .success:
            break
        case .inProgress:
            throw SourceSyncInitializationError.initializationInProgress("Initialization in progress")
        case .failed:
            throw SourceSyncInitializationError.initializationFailed("Initialization failed")
        }
    }
    
    func getActivationDebugData(activation: Activation) -> String {
        return """
        Activation ID: \(activation.id?.description() ?? "")
            Name: \(activation.name ?? "")
            Instances:
                \(getInstancePreviewData(instances: activation.instances ?? []))
        """
    }
    
    private func getInstancePreviewData(instances: [Instance]) -> String {
        return instances.map { instance in
            """
            Instance: \(instance.id?.description() ?? "")
                    Timing: start = \(instance.when?.start?.stringValue ?? "unknown")ms end = \(instance.when?.end?.stringValue ?? "unknown")ms
                    Position: \(instance.position ?? "unknown")
                    Positioning: \(instance.positioning.description())
            """
        }.joined(separator: "\n")
    }
    
    func close() {
        application?.close()
        application = nil
        initStatus = .none
    }
    
    deinit {
        close()
    }
}
