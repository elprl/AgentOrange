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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @Environment(FileViewerViewModel.self) private var fileVM: FileViewerViewModel
    @Environment(NavigationViewModel.self) private var navVM: NavigationViewModel
    @Query(sort: \CDMessageGroup.timestamp, order: .reverse) private var groups: [CDMessageGroup]
    @State private var showSheet: Bool = false

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        @Bindable var navVM = navVM
        @Bindable var chatVM = chatVM
        List(selection: $navVM.selectedSidebarItem) {
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
            chatVM.groupName = chatVM.navTitle ?? ""
        }
        .onChange(of: navVM.selectedSidebarItem) {
            if case .chatGroup(let group) = navVM.selectedSidebarItem {
                fileVM.selectedGroupId = group.groupId
                navVM.selectedDetailedItem = .fileViewer(group: group)
            }
        }
        .onChange(of: groups) {
            if groups.isEmpty {
                fileVM.selectedGroupId = nil
                chatVM.selectedGroupId = nil
                chatVM.selectedGroup = nil
            }
        }
        .alert("Rename", isPresented: $chatVM.shouldShowRenameDialog) {
            TextField(chatVM.navTitle ?? "", text: $chatVM.groupName)
                .textInputAutocapitalization(.never)
            Button("OK", action: {
                Log.view.debug("Save new host")
                chatVM.renameGroup()
            })
            Button("Cancel", role: .cancel) {
                chatVM.groupName = chatVM.navTitle ?? ""
            }
        } message: {
            Text("Enter a new name for this chat group")
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
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("Orange")
                        .font(.title)
                        .bold()
                }
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
        
        Section(header: Text("Logic").font(.title3).foregroundStyle(.accent)) {
            NavigationLink(value: NavigationItem.commandList) {
                Label {
                    Text("Commands")
                        .font(.headline)
                } icon: {
                    Image(systemName: "command")
                }
                .tint(.accent)
            }
            NavigationLink(value: NavigationItem.workflowList) {
                Label {
                    Text("Workflows")
                        .font(.headline)
                } icon: {
                    Image(systemName: "arrow.trianglehead.swap")
                }
                .tint(.accent)
            }
        }

        Section(header: Text("Recent Chats").font(.title3).foregroundStyle(.accent)) {
            if groups.isEmpty {
                Text("No recent chat groups")
                    .foregroundStyle(.secondary)
            }
            ForEach(groups, id: \.groupId) { group in
                NavigationLink(value: NavigationItem.chatGroup(group: group.sendableModel)) {
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
                                chatVM.groupName = group.title
                                chatVM.shouldShowRenameDialog = true
                            }, label: {
                                Label("Rename", systemImage: "pencil")
                            })
                            Button(role: .destructive, action: {
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
