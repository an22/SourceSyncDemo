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
        switch result {
        case .success:
            self.isInitialized = true
        case .failed(let error):
            self.isInitialized = true
            self.errorText = error.localizedDescription
        default:
            break
        }
    }
}
