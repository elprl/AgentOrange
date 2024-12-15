//
//  SendButton.swift
//  AgentOrange
//
//  Created by Paul Leo on 13/12/2024.
//

import SwiftUI
import Combine

struct DebouncedButton<Label> : View where Label : View {
    let action: @MainActor () -> Void
    @ViewBuilder let label: () -> Label
    let debounceInterval: TimeInterval

    @State private var buttonPublisher = PassthroughSubject<Void, Never>()
    @State private var cancellable: AnyCancellable?

    init(debounceInterval: TimeInterval = 0.3, action: @escaping @MainActor () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.debounceInterval = debounceInterval
        self.label = label
    }

    var body: some View {
        Button(action: sendAction) {
            label()
        }
        .onAppear {
           setupDebounce()
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }

    private func sendAction() {
         buttonPublisher.send()
    }
    
    private func setupDebounce() {
       cancellable = buttonPublisher
            .debounce(for: .seconds(debounceInterval), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                action()
            }
    }
}

#Preview {
    DebouncedButton(action: {
        print("Send button tapped")
    }, label: {
        Image(systemName: "paperplane.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 26, height: 26, alignment: .center)
    })
}
