//
//  PreviewViewModel.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//
import SwiftUI
import SourceSyncCore
import AVKit
import Combine

class PreviewViewModel: ObservableObject {
    
    @Published
    var player = AVPlayer()
    @Published
    var videoUrl: String = SourceSyncConstants.videoUrl
    @Published
    var sourceSyncMediaUrl: String = SourceSyncConstants.mediaId
    @Published
    var activationTextList: [String] = []
    @Published
    var lastActivationRefreshTime = ""
    @Published
    var error: String? = nil
    
    private let dateFormatter = DateFormatter()
    private var timeObserver: Any? = nil
    private var content: Content? = nil
    private var cancellables = Set<AnyCancellable>()
    private var timeControlCancelable: AnyCancellable? = nil
    private lazy var progressSubject: any Subject<(Int64, Content), Error> = { createDataSubject() }()
    
    init() {
        dateFormatter.timeStyle = .medium
    }
    
    func submitVideoData() {
        Task { @MainActor in
            await self.initializeContent()
        }
    }
    
    func observeProgress() {
        timeControlCancelable = player.publisher(for: \.timeControlStatus)
            .sink { status in
                switch status {
                case .paused:
                    Logger.shared.logEvent(MediaEvents.pause())
                case .playing:
                    Logger.shared.logEvent(MediaEvents.play())
                default:
                    break
                }
            }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 5, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self else { return }
            guard let content else { return }
            progressSubject.send((Int64(time.seconds.rounded()) * 1000, content))
        }
    }
    
    func stopObservingProgress() {
        timeControlCancelable?.cancel()
        timeControlCancelable = nil
        guard let timeObserver else { return }
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }
    
    @MainActor
    func initializeContent() async {
        let result = await SourceSyncSDKInteractor.shared.initContent(mediaId: sourceSyncMediaUrl)
        switch result {
        case .success(let content):
            self.content = content
            guard let unwrappedUrl = URL(string: videoUrl) else {
                self.error = "Invalid Media URL"
                return
            }
            player.replaceCurrentItem(with: AVPlayerItem(url: unwrappedUrl))
            Logger.shared.logEvent(MediaEvents.playbackMediaReplaced(to: (sourceSyncMediaUrl, videoUrl)))
            progressSubject.send((Int64(0), content))
            self.error = nil
        case .failure(let error):
            self.error = error.localizedDescription
            return
        }
    }
    
    func createDataSubject() -> any Subject<(Int64, Content), Error> {
        let subject = PassthroughSubject<(Int64, Content), Error>()
        subject
            .asyncMap { currentTime, content in
                await SourceSyncSDKInteractor.shared.fetchActivations(content: content, currentTimeMs: currentTime, timeWindowMs: 5000)
            }
            .map { result in
                result.map { activations in
                    activations.map { activation in
                        SourceSyncSDKInteractor.shared.getActivationDebugData(activation: activation)
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: SourceSyncResult.failure(SourceSyncError.unknown("Unknown activation error")))
            .sink { [weak self] result in
                guard let self else { return }
                withAnimation {
                    switch result {
                    case .failure(let error):
                        self.error = error.localizedDescription
                    case .success(let activations):
                        self.error = nil
                        if (activations.isEmpty) {
                            self.activationTextList = ["No activations found"]
                        } else {
                            self.activationTextList = activations
                        }
                    }
                    self.lastActivationRefreshTime = self.dateFormatter.string(from: Date())
                }
            }.store(in: &cancellables)
        return subject
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
