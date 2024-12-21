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
    @Query private var commands: [CDChatCommand]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(commands, id: \.self) { command in
                    NavigationLink {
                        CommandDetailedView(command: command.sendableModel)
                            .environment(viewModel)
                    } label: {
                        CommandRowView(command: command.sendableModel) { event in
                            
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {

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
