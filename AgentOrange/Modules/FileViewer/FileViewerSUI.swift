//
//  ContentView.swift
//  TDCodeReview
//
//  Created by Paul Leo on 12/12/2021.
//

import SwiftUI

struct FileViewerSUI: View {
    @Environment(FileViewerViewModel.self) private var viewModel: FileViewerViewModel

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        ScrollView {
            LazyVStack(spacing: 0) {
                pasteBtn
                ForEach(viewModel.rows.indices, id: \.self) { index in
                    Text(viewModel.rows[index])
                        .padding(.horizontal)
                        .id(index)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top)
            .padding(.bottom)
        }
        .background(Color.black)
        .navigationTitle("Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    private var pasteBtn: some View {
        if viewModel.rows.isEmpty {
            Button("Paste Code") {
                let pasteboard = UIPasteboard.general
                if let string = pasteboard.string {
                    viewModel.parseCode(code: string)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
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
        .environment(FileViewerViewModel(code: code))
}

#Preview("No code") {
    FileViewerSUI()
        .environment(FileViewerViewModel())
}


#endif
