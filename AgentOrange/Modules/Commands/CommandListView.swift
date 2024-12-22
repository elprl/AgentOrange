//
//  CommandListView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI
import SwiftData

struct CommandListView: View {
    @Environment(CommandListViewModel.self) private var viewModel: CommandListViewModel
    @Environment(NavigationViewModel.self) private var navVM: NavigationViewModel
    @Query private var commands: [CDChatCommand]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(commands, id: \.self) { command in
                    Button {
                        navVM.selectedDetailedItem = .commandDetail(command: command.sendableModel)
                    } label: {
                        CommandRowView(command: command.sendableModel) { event in
                            
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
                .animation(.default, value: commands.count)
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.createNewCommand()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                })
            }
        }
        .navigationBarTitle("Commands")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        CommandListView()
    }
}
