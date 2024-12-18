//
//  SettingsView.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//

import SwiftUI

enum NavigationItem {
    case openAISettings
    case openAIInputSettings
    case geminiSettings
    case geminiInputSettings
    case customAISettings
    case claudeSettings
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("darkLightAutoMode") private var darkLightAutoMode: UIUserInterfaceStyle = .unspecified
    @State private var showAlert: Bool = false

    private struct Constants {
        static let appId = "6511210635"
    }

    var body: some View {
        NavigationStack {
            List {
                appPreferences
                aiSettings
                data
                miscellaneous
            }
            .listStyle(.insetGrouped)
            .tint(.accent)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavigationItem.self) { navItem in
                switch navItem {
                case .customAISettings:
                    CustomAISettingsSUI()
                default:
                    EmptyView()
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
            .toolbarBackground(.accent, for: .navigationBar, .bottomBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(role: .cancel, action: {
                        self.dismiss()
                    }, label: {
                        Text("Cancel")
                            .foregroundStyle(.white)
                    })
                }
            }
            .alert("Are you sure?", isPresented: $showAlert) {
                Button("Delete All", role: .destructive, action: {
                    Log.view.debug("Save new host")
                    deleteAllData()
                })
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This deletes all data including chats and cached code snippets. Are you sure?")
            }
            .preferredColorScheme(ColorScheme(darkLightAutoMode)) 
        }
    }
    
    @ViewBuilder
    private var appPreferences: some View {
        Section(header: SectionHeaderBlock(title: "App Preferences", description: "")) {
            Picker(selection: $darkLightAutoMode, label: Text("Visual Mode")) {
                Text("Automatic").font(.callout).tag(UIUserInterfaceStyle.unspecified)
                Text("Dark").font(.callout).tag(UIUserInterfaceStyle.dark)
                Text("Light").font(.callout).tag(UIUserInterfaceStyle.light)
            }
            .tint(colorScheme == .dark ? .accent : .brown)
        }
    }
    
    @ViewBuilder
    var aiSettings: some View {
        Section(header: SectionHeaderBlock(title: "AI SETUP", description: "Setup Integrations with AI Models")) {
            NavigationLink(value: NavigationItem.customAISettings) {
                HStack {
                    Image(systemName: "brain")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text("Custom AI Server")
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            .foregroundStyle(.primary, .accent)
        }
    }
    
    @ViewBuilder
    private var miscellaneous: some View {
        Section(header: SectionHeaderBlock(title: "Miscellaneous", description: "")) {
            NavigationLink("Licenses & Thanks") {
                List {
                    Text("Factory\nhttps://github.com/hmlongco/Factory")
                    Text("Splash\nhttps://github.com/JohnSundell/Splash")
                    Text("MarkdownUI\nhttps://github.com/gonzalezreal/swift-markdown-ui")
                }
                .tint(.accent)
                .navigationTitle("Licenses & Thanks")
                .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
                .toolbarBackground(.accent, for: .navigationBar, .bottomBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
            .foregroundStyle(.primary, .accent)
            version
        }
    }
    
    @ViewBuilder
    private var data: some View {
        Section(header: SectionHeaderBlock(title: "Data", description: "")) {
            Button(role: .destructive, action: {
                showAlert = true
            }, label: {
                Text("Delete All Data")
                    .foregroundStyle(.red)
            })
        }
    }
    
    @ViewBuilder
    private var version: some View {
        HStack {
            Text("Version")
                .lineLimit(1)
                .foregroundStyle(.primary)
            Spacer()
            Text(versionString)
                .font(.callout)
                .lineLimit(1)
                .foregroundStyle(.accent)
        }
        .foregroundStyle(.primary, .accent)
    }
    
    private var versionString: String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return "VX\(version) (\(build))"
        }
        return "unknown"
    }
    
    private func deleteAllData() {
        do {
            try modelContext.delete(model: CDChatMessage.self)
            try modelContext.delete(model: CDMessageGroup.self)
            try modelContext.delete(model: CDCodeSnippet.self)
        } catch {
            print("Failed to delete students.")
        }
    }
}

struct SectionHeaderBlock: View {
    var title: String = ""
    var description: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
