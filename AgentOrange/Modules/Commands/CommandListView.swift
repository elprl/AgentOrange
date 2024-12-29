//
//  CommandListView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI
import SwiftData

struct CommandListView: View {
    @State private var viewModel: CommandListViewModel
    @Environment(NavigationViewModel.self) private var navVM: NavigationViewModel
    @Query(sort: \CDChatCommand.timestamp, order: .reverse) private var commands: [CDChatCommand]
    
    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: CommandListViewModel(modelContext: modelContext))
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                if commands.isEmpty {
                    Text("No commands found.\nTap + to add a new command.")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                ForEach(commands, id: \.self) { command in
                    Button {
                        navVM.selectedDetailedItem = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navVM.selectedDetailedItem = .commandDetail(command: command.sendableModel)
                        }
                    } label: {
                        CommandRowView(command: command.sendableModel) { event in
                            switch event {
                            case .delete:
                                viewModel.delete(command: command.sendableModel)
                            case .duplicate:
                                viewModel.duplicate(command: command.sendableModel)
                            default: break
                            }
                        }
                        .overlay {
                            if case let .commandDetail(selectedCommand) = navVM.selectedDetailedItem, selectedCommand.name == command.name {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accent, lineWidth: 3)
                            }
                        }
                    }
                }
                .transition(.slide)
                .animation(.easeInOut, value: commands.count)
            }
            .padding()
        }
        .alert("Are you sure?", isPresented: $viewModel.showAlert) {
            Button("Delete", role: .destructive, action: {
                Task { @MainActor in
                    viewModel.deleteAllCommands()
                }
            })
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text("Delete ALL commands?")
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.createNewCommand()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                })
                Menu {
                    Button(action: {
                        viewModel.resetDefaults()
                    }, label: {
                        Label("Reset to Defaults", systemImage: "arrow.3.trianglepath")
                            .foregroundColor(.white)
                    })
                    Button(action: {
                        viewModel.showAlert = true
                    }, label: {
                        Label("Delete All", systemImage: "trash")
                            .foregroundColor(.white)
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
                .menuOrder(.fixed)
                .highPriorityGesture(TapGesture())
            }
        }
        .navigationBarTitle("Commands")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: viewModel.selectedCommand) {
            navVM.selectedDetailedItem = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let command = viewModel.selectedCommand {
                    navVM.selectedDetailedItem = .commandDetail(command: command)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommandListView(modelContext: PreviewController.commandsPreviewContainer.mainContext)
            .environment(NavigationViewModel.mock())
            .modelContext(PreviewController.commandsPreviewContainer.mainContext)
    }
}
