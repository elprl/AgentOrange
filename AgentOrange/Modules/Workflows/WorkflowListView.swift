//
//  WorkflowListView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI

struct WorkflowListView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<10) { index in
                    NavigationLink(destination: Text("Workflow \(index)")) {
                        Text("workflow \(index)")
                            .padding()
                            .background(Color(.systemGray5))
                    }
                }
            }
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
        .navigationBarTitle("Workflows")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    WorkflowListView()
}
