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
        VStack {
            HStack {
                VStack {
                    if (viewModel.error != nil) {
                        Text(viewModel.error ?? "")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    Text("Media URL:")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Media URL", text: $viewModel.videoUrl)
                        .textFieldStyle(.roundedBorder)
                    Text("Media ID")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Media ID", text: $viewModel.sourceSyncMediaUrl)
                        .textFieldStyle(.roundedBorder)
                }
                Button("Submit") {
                    viewModel.submitVideoData()
                }
            }.padding()
            VideoPlayer(player: viewModel.player)
            List {
                Text("Last activation refresh time: \(viewModel.lastActivationRefreshTime)")
                ForEach(viewModel.activationTextList, id: \.self) {
                    Text("\($0)")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .listStyle(.plain)
            .listRowBackground(Color.clear)
        }
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
