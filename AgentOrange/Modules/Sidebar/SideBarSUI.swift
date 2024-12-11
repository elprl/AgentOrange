//
//  SideBarSUI.swift
//  AgentOrange
//
//  Created by Paul Leo on 17/03/2022.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct SideBarSUI: View {
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @Environment(FileViewerViewModel.self) private var fileVM: FileViewerViewModel
    @Query(sort: \CDMessageGroup.timestamp, order: .reverse) private var groups: [CDMessageGroup]
    @State private var showSheet: Bool = false

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        @Bindable var chatVM = chatVM
        List(selection: $chatVM.selectedGroup) {
            header
            dashboard
        }
        .listStyle(.sidebar)
        .tint(.accent)
        .navigationBarTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet, content: {
            SettingsView()
        })
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    chatVM.addGroup()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                })
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button(action: {
                    self.showSheet = true
                }, label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                })
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.accent, for: .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar, .bottomBar)
        .task {
            if let group = groups.first {
                chatVM.selectedGroup = group.sendableModel
                chatVM.selectedGroupId = group.groupId
                fileVM.selectedGroupId = group.groupId
            }
        }
        .onChange(of: chatVM.selectedGroup) {
            fileVM.selectedGroupId = chatVM.selectedGroup?.id
        }
    }
    
    @ViewBuilder
    private var logo: some View {
        ZStack {
            Circle()
                .fill(.accent)
                .frame(width: 60, height: 60)
            Image("biohazard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundColor(.black)
            Circle()
                .stroke(.black, lineWidth: 2)
                .frame(width: 60, height: 60)
                .shadow(color: .gray, radius: 2)
        }
    }
    
    @ViewBuilder
    private var header: some View {
        HStack {
            logo
            ZStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Agent")
                        .font(.title2)
                        .bold()
                        .underline()
                        .foregroundColor(.gray)
                    Text("Orange")
                        .font(.title)
                        .bold()
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Agent")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("Orange")
                        .font(.title)
                        .bold()
                }
                .scaleEffect(0.97)
                .shadow(radius: 1)
            }
        }
        .foregroundColor(.accent)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.top, 30)
    }
    
    @ViewBuilder
    private var dashboard: some View {
        @Bindable var chatVM = chatVM

        Section(header: Text("Recent").font(.title3).foregroundColor(.accent)) {
            ForEach(groups, id: \.groupId) { group in
                NavigationLink(value: group.sendableModel) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(group.title)
                                .font(.headline)
//                                .foregroundStyle(group.groupId == chatVM.selectedGroupId ? .accent : .primary)
                            Text(group.timestamp.formatted(date: .abbreviated, time: .standard))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Menu {
                            Button(action: {
                                chatVM.delete(group: group)
                            }, label: {
                                Label("Delete", systemImage: "trash")
                            })
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.white)
                        }
                        .menuOrder(.fixed)
                        .highPriorityGesture(TapGesture())
                    }
                    .tint(.accent)
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        SideBarSUI()
            .environment(AIChatViewModel.mock())
            .environment(FileViewerViewModel.mock())
            .modelContext(PreviewController.messageGroupPreviewContainer.mainContext)
    }
}

#endif
