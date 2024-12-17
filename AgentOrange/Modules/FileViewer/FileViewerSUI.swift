//
//  FileViewerSUI.swift
//  AgentOrange
//
//  Created by Paul Leo on 12/12/2021.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import SwiftData
import MarkdownUI
import Splash

struct FileViewerSUI: View {
    @Environment(\.colorScheme) private var colorScheme
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
                ScrollView(showsIndicators: true) {
                    markdown
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
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
                            viewModel.addPasted(code: code)
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
                        Image(systemName: "clipboard")
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
    private var markdown: some View {
        Markdown(viewModel.cachedCode)
            .markdownBlockStyle(\.codeBlock) {
                codeBlock($0)
            }
            .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
    }
    
    @ViewBuilder
    private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(configuration.language ?? "plain text")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(theme.plainTextColor))
                Spacer()
                
                Image(systemName: "clipboard")
                    .onTapGesture {
                        copyToClipboard(configuration.content)
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background {
                Color(theme.backgroundColor)
            }
            
            Divider()
            
            ScrollView(.horizontal) {
                configuration.label
                    .relativeLineSpacing(.em(0.25))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding()
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .markdownMargin(top: .em(0.8), bottom: .em(0.8))
    }
    
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch self.colorScheme {
        case .dark:
            return .wwdc17(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }
    
    private func copyToClipboard(_ string: String) {
#if os(macOS)
        if let pasteboard = NSPasteboard.general {
            pasteboard.clearContents()
            pasteboard.setString(string, forType: .string)
        }
#elseif os(iOS)
        UIPasteboard.general.string = string
#endif
    }
    
    @ViewBuilder
    private var pasteBtn: some View {
        VStack {
            Button(action: {
                let pasteboard = UIPasteboard.general
                if let code = pasteboard.string {
                    viewModel.addPasted(code: code)
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
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(snippet.title)
                                        .lineLimit(1)
                                        .foregroundStyle(.primary)
                                    HStack {
                                        if viewModel.isScoped(id: snippet.codeId) {
                                            Text("S")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.white)
                                                .padding(3)
                                                .background(content: {
                                                    Circle()
                                                        .fill(Color.accent)
                                                })
                                        }
                                        Text(subTitle)
                                            .lineLimit(1)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                            } else {
                                Text(snippet.title)
                                    .lineLimit(1)
                                    .foregroundStyle(.primary)
                                    .padding(8)
                            }
                            Menu {
                                if viewModel.isScoped(id: snippet.codeId) {
                                    Button(action: {
                                        viewModel.removeFromScope(snippetId: snippet.codeId)
                                    }, label: {
                                        
                                        Label("Remove from Scope", systemImage: "minus")
                                            .foregroundStyle(.white)
                                    })
                                } else {
                                    Button(action: {
                                        viewModel.addToScope(snippet: snippet.sendableModel)
                                    }, label: {
                                        
                                        Label("Add to Scope", systemImage: "plus")
                                            .foregroundStyle(.white)
                                    })
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
                                    Label("Hide", systemImage: "xmark")
                                        .foregroundStyle(.white)
                                })
                            } label: {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .contentShape(Rectangle())
                                    .rotationEffect(.degrees(90))
                            }
                            .menuOrder(.fixed)
                            .highPriorityGesture(TapGesture())
                            .padding(.trailing, 8)
                        }
                        .background(snippet.codeId == (viewModel.selectedSnippet?.codeId ?? "1") ? Color.accent : Color.accent.opacity(0.2))
                        .clipShape(.rect(topLeadingRadius: 8, topTrailingRadius: 8))
                        .padding(.horizontal, 4)
                        .shadow(radius: snippet.codeId == (viewModel.selectedSnippet?.codeId ?? "1") ? 2 : 0, y: 2)
                    })
                }
            }
        }
        .padding(.top, 4)
        .padding(.horizontal)
        .background(Color.gray)
        .padding(.bottom, -8)
    }
}

#if DEBUG

#Preview("Code Viewer") {
    NavigationStack {
        FileViewerSUI(groupId: "1")
            .environment(FileViewerViewModel.mock())
            .environment(AIChatViewModel.mock())
            .modelContainer(PreviewController.codeSnippetPreviewContainer.mainContext.container)
    }
}

#Preview("No code") {
    NavigationStack {
        FileViewerSUI(groupId: "1")
            .environment(AIChatViewModel.mock())
            .environment(FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext))
//            .modelContainer(PreviewController.codeSnippetPreviewContainer.mainContext.container)
    }
}

#endif
