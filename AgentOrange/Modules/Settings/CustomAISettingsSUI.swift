//
//  CustomAISettingsSUI.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/04/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct CustomAISettingsSUI: View {
    @StateObject private var viewModel = CustomAISettingsViewModel()
    
    var body: some View {
        Form {
            inputRows
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Custom AI Server Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Enter New Host", isPresented: $viewModel.shouldShowHostDialog) {
            TextField(viewModel.customAIHost, text: $viewModel.newHostText)
                .textInputAutocapitalization(.never)
            Button("OK", action: {
                Log.view.debug("Save new host")
                self.viewModel.onSaveNewHost()
            })
            Button("Cancel", role: .cancel) {
                self.viewModel.onCancelNewHost()
            }
        } message: {
            Text("Enter the URL of the Custom AI server (e.g. http://localhost:1234 )")
        }
        .alert("Enter New Model", isPresented: $viewModel.shouldShowModelDialog) {
            TextField(viewModel.customAIModel, text: $viewModel.newModelText)
                .textInputAutocapitalization(.never)
            Button("OK", action: {
                Log.view.debug("Save new host")
                self.viewModel.onSaveNewModel()
            })
            Button("Cancel", role: .cancel) {
                self.viewModel.onCancelNewModel()
            }
        } message: {
            Text("Enter the name of the new chat model (e.g. Hermes)")
        }
        .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
        .toolbarBackground(.accent, for: .navigationBar, .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar)
   }
    
    @ViewBuilder
    var inputRows: some View {
        Section(header: SectionHeaderBlock(title: "Custom AI", description: "Setup integration with custom server that behaves like OpenAI's streaming API (/v1/chat/completions)")) {
            HStack {
                Text("Server Host").lineLimit(1).foregroundColor(.primary)
                Spacer()
                if viewModel.customAIHost.isEmpty {
                    Text("e.g. http://localhost:1234").lineLimit(1).foregroundStyle(.secondary).opacity(0.4).tint(.accent)
                } else {
                    Text(viewModel.customAIHost).lineLimit(1).foregroundStyle(.secondary).tint(.accent)
                }
                Button {
                    viewModel.onEditHost()
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accent)
                        .frame(width: 20, height: 20)
                }
                .contentShape(Rectangle())
            }
            HStack {
                Text("Chat Model").lineLimit(1).foregroundColor(.primary)
                Spacer()
                if viewModel.customAIModel.isEmpty {
                    Text("e.g. Hermes").lineLimit(1).foregroundStyle(.secondary).opacity(0.4).tint(.accent)
                } else {
                    Text(viewModel.customAIModel).lineLimit(1).foregroundColor(.secondary).tint(.accent)
                }
                Button {
                    viewModel.onEditModel()
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accent)
                        .frame(width: 20, height: 20)
                }
                .contentShape(Rectangle())
            }
            errorMessage
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
    }
    
    @ViewBuilder
    var errorMessage: some View {
        if !viewModel.errorMessage.isEmpty {
            Text(verbatim: viewModel.errorMessage)
                .foregroundStyle(.red)
        }
    }
}

#if DEBUG

#Preview {
    CustomAISettingsSUI()
}

#endif
