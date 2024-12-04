//
//  ContentView.swift
//  TDCodeReview
//
//  Created by Paul Leo on 12/12/2021.
//

import SwiftUI

struct FileViewerSUI: View {
    @Environment(FileViewerViewModel.self) private var viewModel: FileViewerViewModel
    @State private var isFilePickerPresented: Bool = false
    @State private var fileContent: String = ""

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        ScrollView {
            LazyVStack(spacing: 0) {
                pasteBtn
                codeVersions
                ForEach(viewModel.currentRows.indices, id: \.self) { index in
                    Text(viewModel.currentRows[index])
                        .padding(.horizontal)
                        .id(index)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top)
            .padding(.bottom)
        }
        .sheet(isPresented: $isFilePickerPresented) {
            DocumentPickerView() { code in
                viewModel.displayCode(code: code)
            }
        }
        .background(Color.black)
        .navigationTitle("Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("", systemImage: "document.on.clipboard.fill") {
                    let pasteboard = UIPasteboard.general
                    if let code = pasteboard.string {
                        viewModel.displayCode(code: code)
                    }
                }
                Button("", systemImage: "folder.fill") {
                    isFilePickerPresented = true
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    private var pasteBtn: some View {
        if viewModel.rows.isEmpty {
            HStack {
                Button("Paste Code", systemImage: "document.on.clipboard.fill") {
                    let pasteboard = UIPasteboard.general
                    if let code = pasteboard.string {
                        viewModel.displayCode(code: code)
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Browse...", systemImage: "folder.fill") {
                    isFilePickerPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .tint(.orange)
        }
    }
    
    @ViewBuilder
    private var codeVersions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.versions, id: \.self) { version in
                    Button(action: {
                        print("Version \(version.versionString)")
                        viewModel.selectedVersion = version.version
                    }, label: {
                        Text(version.versionString)
                            .padding(8)
                            .foregroundStyle(.white)
                            .background(version.version == viewModel.selectedVersion ? .orange : .gray)
                            .cornerRadius(8)
                            .padding(4)
                    })
                }
            }
        }
        .padding(.horizontal)
    }
}

#if DEBUG

#Preview("Code Viewer") {
    let code = """
struct FileViewerSUI: View {
    @State var viewModel: FileViewerViewModel = FileViewerViewModel()

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.rows.indices, id: \\.self) { index in
                    Text(viewModel.rows[index])
                        .padding(.horizontal)
                        .id(index)
                }
            }
            .padding(.top)
            .padding(.bottom, 100)
        }
        .navigationTitle("Code")
        .navigationBarTitleDisplayMode(.inline)
    }
}
"""
    FileViewerSUI()
        .environment(FileViewerViewModel())
}

#Preview("No code") {
    FileViewerSUI()
        .environment(FileViewerViewModel())
}


#endif
