//
//  PlatformInitView.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//

import SwiftUI

struct PlatformInitView: View {
    
    @StateObject var viewModel: PlatformInitViewModel = .init()
    
    var body: some View {
        VStack(alignment: .center) {
            if (!viewModel.isInitialized) {
                InitializationProgressView()
            } else {
                if (viewModel.errorText == nil) {
                    InitializationSuccessView()
                } else {
                    InitializationFailedView(errorText: viewModel.errorText ?? "")
                }
            }
        }
        .padding()
        .task {
            await viewModel.startInitializationProcess()
        }.navigationTitle(Text("SDK Initialization"))
    }
}

private struct InitializationProgressView: View {
    
    var body: some View {
        Spacer()
        ProgressView()
        Text("Initializing platform...")
        Spacer()
    }
}

private struct InitializationFailedView: View {
    @State var errorText: String
    
    var body: some View {
        Spacer()
        Text("Initialization failed")
            .foregroundStyle(.red)
        Text(errorText)
            .foregroundStyle(.red)
        Spacer()
    }
}

private struct InitializationSuccessView: View {
    @EnvironmentObject var navigationHolder: NavigationHolder
    
    var body: some View {
        Spacer()
        Text("Initialized successfully")
        Spacer()
        Button("Continue") {
            navigationHolder.navigateTo(route: PreviewDestination())
        }.buttonStyle(ActionButton())
    }
}

#Preview {
    PlatformInitView()
}
