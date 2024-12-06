//
//  SideBarSUI.swift
//  AgentOrange
//
//  Created by Paul Leo on 17/03/2022.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct SideBarSUI: View {
    @Binding var selection: String?


    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        List(selection: $selection) {
            header
            dashboard
        }
        .listStyle(.sidebar)
        .tint(.accent)
        .navigationBarTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showSheet, content: {
//            SettingsSUI()
//                .environmentObject(settingsVM)
//        })
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
//                    self.showSheet = true
                }, label: {
                    Image(systemName: "plus.bubble")
                        .foregroundColor(.white)
                })
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
//                    self.showSheet = true
                }, label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                })
                Button(action: {
//                    self.selection = NavigationItem.help
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                })
                Spacer()
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.accent, for: .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar, .bottomBar)
    }
    
    @ViewBuilder
    private var logo: some View {
        ZStack {
            Circle()
                .fill(.accent)
                .frame(width: 60, height: 60)
            Image("skull")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
            Circle()
                .stroke(.white, lineWidth: 2)
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
        Section(header: Text("DASHBOARD").font(.title3).foregroundColor(.accent)) {
            NavigationLink(value: "code") {
                Label {
                    Text("New Chat")
                        .font(.headline)
                } icon: {
                    Image(systemName: "text.bubble")
                }
                .tint(.accent)
            }
        }
    }
}

#if DEBUG

#Preview {
    SideBarSUI(selection: .constant("code"))
}

#endif
