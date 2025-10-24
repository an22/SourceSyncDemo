//
//  ContentView.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    private var navigationHolder = NavigationHolder()
    
    var body: some View {
        NavigationStack(path: $navigationHolder.navigationPath) {
            PlatformInitView()
                .navigationDestination(for: PlatformDestination.self) { _ in
                    PlatformInitView()
                }
                .navigationDestination(for: PreviewDestination.self) { _ in
                    PreviewView()
                }
        }
        .environmentObject(navigationHolder)
    }
}


