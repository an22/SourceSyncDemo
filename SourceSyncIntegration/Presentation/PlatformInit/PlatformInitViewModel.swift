//
//  PlatformInitViewModel.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//

import SwiftUI
import SourceSyncCore


class PlatformInitViewModel: ObservableObject {
    
    @Published
    var isInitialized: Bool = false
    
    @Published
    var errorText: String? = nil
    
    @MainActor
    func startInitializationProcess() async {
        let result = await SourceSyncSDKInteractor.shared.initialize()
        withAnimation {
            switch result {
            case .success:
                self.isInitialized = true
                self.errorText = nil
            case .failed(let error):
                self.errorText = error.localizedDescription
                self.isInitialized = true
            default:
                break
            }
        }
    }
    
    func retryInit() {
        Task { @MainActor in
            self.isInitialized = false
            await startInitializationProcess()
        }
    }
}
