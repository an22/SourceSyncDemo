//
//  PreviewView.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//

import SwiftUI
import AVKit

struct PreviewView: View {
    
    @StateObject var viewModel: PreviewViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(player: viewModel.player)
                .frame(height: 250)
            Form {
                Section("Enter media data") {
                    LabeledContent {
                        TextField("Media URL", text: $viewModel.videoUrl)
                    } label: {
                        Text("Media URL")
                    }
                    LabeledContent {
                        TextField("Media ID", text: $viewModel.sourceSyncMediaUrl)
                    } label: {
                        Text("Media ID")
                    }
                }
                Button("Submit") {
                    viewModel.submitVideoData()
                }
                .buttonStyle(ActionButton())
                .listRowInsets(EdgeInsets())
                
                Section("Last activations refresh time") {
                    Text("\(viewModel.lastActivationRefreshTime)")
                }
                if (viewModel.error != nil) {
                    Section("Activations error") {
                        Text(viewModel.error ?? "")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
                Section("Activations") {
                    ForEach(viewModel.activationTextList, id: \.self) {
                        Text("\($0)")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }.listSectionSpacing(.compact)
        }
        .background(.background.secondary)
        .onAppear {
            viewModel.observeProgress()
        }
        .onDisappear {
            viewModel.stopObservingProgress()
        }
        .task {
            await viewModel.initializeContent()
        }
        .navigationBarTitle("SourceSync SDK Usage Example")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PreviewView()
}
