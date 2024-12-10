//
//  FileViewerSUI.swift
//  AgentOrange
//
//  Created by Paul Leo on 12/12/2021.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import SwiftData

struct FileViewerSUI: View {
    @Environment(FileViewerViewModel.self) private var viewModel: FileViewerViewModel
    @State private var isFilePickerPresented: Bool = false
    @State private var fileContent: String = ""
    @AppStorage(UserDefaults.Keys.wrapText) var isWrapText: Bool = false
    @Query private var snippets: [CDCodeSnippet]
    
    init(groupId: String? = nil) {
        if let groupId {
            _snippets = Query(filter: #Predicate<CDCodeSnippet> { $0.groupId == groupId && $0.isVisible == true }, sort: \CDCodeSnippet.timestamp, order: .forward)
        }
    }

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            if !snippets.isEmpty {
                browserTabs
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
                viewModel.addCodeSnippet(code: code, tag: filename)
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
                            viewModel.addCodeSnippet(code: code, tag: "PastedCode")
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
            if !snippets.isEmpty {
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
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let snippet = snippets.first {
                    viewModel.selectTab(snippet: snippet.sendableModel)
                }
            }
        }
    }
    
    @ViewBuilder
    private var pasteBtn: some View {
        VStack {
            Button(action: {
                let pasteboard = UIPasteboard.general
                if let code = pasteboard.string {
                    viewModel.addCodeSnippet(code: code, tag: "PastedCode")
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
    
    @ViewBuilder
    private var browserTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(snippets, id: \.self) { snippet in
                    Button(action: {
                        viewModel.selectTab(snippet: snippet.sendableModel)
                    }, label: {
                        HStack {
                            if let subTitle = snippet.subTitle {
                                VStack(alignment: .leading) {
                                    Text(snippet.title)
                                        .lineLimit(1)
                                        .foregroundStyle(.white)
                                    Text(subTitle)
                                        .lineLimit(1)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(8)
                            } else {
                                Text(snippet.title)
                                    .lineLimit(1)
                                    .foregroundStyle(.white)
                                    .padding(8)
                            }
                            Button(action: {
                                if let selectedSnippet = viewModel.selectedSnippet, selectedSnippet.id == snippet.codeId {
                                    if let index = snippets.firstIndex(where: { $0.codeId == selectedSnippet.id }) {
                                        if index > 0 {
                                            viewModel.selectTab(snippet: snippets[index - 1].sendableModel)
                                        } else if snippets.count > 1 {
                                            viewModel.selectTab(snippet: snippets[1].sendableModel)
                                        }
                                    }
                                }
                                viewModel.hide(snippet: snippet.sendableModel)
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            })
                            .padding(.trailing, 8)
                        }
                        .background(snippet.codeId == (viewModel.selectedSnippet?.codeId ?? "1") ? Color(uiColor: UIColor.systemBackground) : Color.gray.opacity(0.7))
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
        FileViewerSUI(groupId: "1")
            .environment(FileViewerViewModel.mock())
    }
}

#Preview("No code") {
    NavigationStack {
        FileViewerSUI(groupId: "1")
            .environment(FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext))
    }
}

#endif
