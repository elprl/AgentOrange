//
//  FileViewerSUI.swift
//  AgentOrange
//
//  Created by Paul Leo on 12/12/2021.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct FileViewerSUI: View {
    @Environment(FileViewerViewModel.self) private var viewModel: FileViewerViewModel
    @State private var isFilePickerPresented: Bool = false
    @State private var fileContent: String = ""
    @AppStorage(UserDefaults.Keys.wrapText) var isWrapText: Bool = false

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            if viewModel.hasCode {
                codeVersions
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.currentRows.indices, id: \.self) { index in
                            if isWrapText {
                                Text(viewModel.currentRows[index])
                                    .padding(.horizontal)
                                    .id(index)
                                    .lineLimit(nil)
                                    .textSelection(.enabled)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text(viewModel.currentRows[index])
                                    .padding(.horizontal)
                                    .id(index)
                                    .lineLimit(1)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.bottom)
                }
            } else {
                pasteBtn
            }
        }
        .sheet(isPresented: $isFilePickerPresented) {
            DocumentPickerView() { filename, code in
                viewModel.addCode(code: code, tag: filename)
            }
        }
//        .background(Color.black)
        .navigationTitle("Code Viewer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        let pasteboard = UIPasteboard.general
                        if let code = pasteboard.string {
                            viewModel.addCode(code: code, tag: "PastedCode")
                        }
                    }, label: {
                        Label("Paste Code", systemImage: "document.on.clipboard.fill")
                            .foregroundStyle(.white)
                    })
                    Button(action: {
                        isFilePickerPresented = true
                    }, label: {
                        Label("Browse Files", systemImage: "folder.fill")
                            .foregroundStyle(.white)
                    })
                    Button {
                        isWrapText.toggle()
                    } label: {
                        Label("Wrap Text", systemImage: isWrapText ? "checkmark" : "xmark")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
                .menuOrder(.fixed)
                .highPriorityGesture(TapGesture())
                

            }
            if viewModel.hasCode {
                ToolbarItemGroup(placement: .bottomBar) {
                    if let time = viewModel.currentTimestamp {
                        Text("Added: \(time)")
                    }
                    Spacer()
                    Button(action: {
                        viewModel.copyToClipboard()
                    }, label: {
                        Image(systemName: "document.on.document.fill")
                            .foregroundStyle(.white)
                    })
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
        .toolbarBackground(.accent, for: .navigationBar, .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar, .bottomBar)
    }
    
    @ViewBuilder
    private var pasteBtn: some View {
        if viewModel.currentRows.isEmpty {
            VStack {
                Button(action: {
                    let pasteboard = UIPasteboard.general
                    if let code = pasteboard.string {
                        viewModel.addCode(code: code, tag: "PastedCode")
                    }
                }, label: {
                    Label("Paste Code", systemImage: "document.on.clipboard.fill")
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 30)
               })
                .buttonStyle(.borderedProminent)
                Button(action: {
                    isFilePickerPresented = true
                }, label: {
                    Label("Browse Files", systemImage: "folder.fill")
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 30)
                })
                .buttonStyle(.borderedProminent)
            }
            .tint(.accent)
        }
    }
    
    @ViewBuilder
    private var codeVersions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.versions, id: \.self) { version in
                    Button(action: {
                        print("Version \(version.tag)")
                        viewModel.selectTab(id: version.id)
                    }, label: {
                        HStack {
                            Text(version.tag)
                                .padding(8)
                                .foregroundStyle(.white)
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            })
                            .padding(.trailing, 8)
                        }
                        .background(version.id == viewModel.selectedId ? Color(uiColor: UIColor.systemBackground) : .gray.opacity(0.7))
                        .clipShape(.rect(topLeadingRadius: 8, topTrailingRadius: 8))
                        .padding(.horizontal, 4)
                    })
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .background(Color.accent)
        .padding(.bottom, -8)
    }
}

#if DEBUG

#Preview("Code Viewer") {
    NavigationStack {
        FileViewerSUI()
            .environment(FileViewerViewModel.mock())
    }
}

#Preview("No code") {
    NavigationStack {
        FileViewerSUI()
            .environment(FileViewerViewModel())
    }
}

#endif
