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

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            pasteBtn
            codeVersions
            Divider()
            ScrollView {
                LazyVStack(spacing: 0) {
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
        }
        .sheet(isPresented: $isFilePickerPresented) {
            DocumentPickerView() { filename, code in
                viewModel.addCode(code: code, tag: filename)
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
                        viewModel.addCode(code: code, tag: "PastedCode")
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
        if viewModel.currentRows.isEmpty {
            HStack {
                Button("Paste Code", systemImage: "document.on.clipboard.fill") {
                    let pasteboard = UIPasteboard.general
                    if let code = pasteboard.string {
                        viewModel.addCode(code: code, tag: "PastedCode")
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Browse...", systemImage: "folder.fill") {
                    isFilePickerPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .tint(.orange)
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private var codeVersions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.versions, id: \.self) { version in
                    Button(action: {
                        print("Version \(version.tag)")
                        viewModel.selectedId = version.id
                    }, label: {
                        Text(version.tag)
                            .padding(8)
                            .foregroundStyle(.white)
                            .background(version.id == viewModel.selectedId ? .orange : .gray)
                            .cornerRadius(8)
                            .padding(4)
                    })
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

#if DEBUG

#Preview("Code Viewer") {
//    let code = """
//struct FileViewerSUI: View {
//    @State var viewModel: FileViewerViewModel = FileViewerViewModel()
//
//    var body: some View {
//#if DEBUG
//        let _ = Self._printChanges()
//#endif
//        ScrollView {
//            LazyVStack(spacing: 0) {
//                ForEach(viewModel.rows.indices, id: \\.self) { index in
//                    Text(viewModel.rows[index])
//                        .padding(.horizontal)
//                        .id(index)
//                }
//            }
//            .padding(.top)
//            .padding(.bottom, 100)
//        }
//        .navigationTitle("Code")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//"""
    FileViewerSUI()
        .environment(FileViewerViewModel())
}

#Preview("No code") {
    FileViewerSUI()
        .environment(FileViewerViewModel())
}


#endif
