//
//  ContentView.swift
//  spm-watchos WatchKit Extension
//
//  Created by Adam Mcgrath on 22/12/2021.
//

import SwiftUI
import Auth0
import Combine

let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

let at = "at"

let user = "user"

func asyncAwait() async {
    do {
        let user = try await Auth0
            .users(token: at)
            .logging(enabled: true)
            .get(user)
            .start()
        print("User with metadata: \(user)")
    } catch {
        print("Failed with \(error)")
    }
}

func asyncRevoke() async {
    do {
        try await credentialsManager.revoke()
        print("Success")
    } catch {
        print("Failed with \(error)")
    }
}


struct ContentView: View {
    @State var cancellables = Set<AnyCancellable>()
    
    func combineReq() {
        Auth0
            .users(token: at)
            .logging(enabled: true)
            .get(user)
            .publisher()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed with \(error)")
                }
            }, receiveValue: { user in
                print("User with metadata: \(user)")
            }).store(in: &cancellables)
    }
    
    func combineRevoke() {
        credentialsManager
            .revoke()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed with \(error)")
                }
                print("Success")
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Button("async/await request") { Task.init { await asyncAwait() } }
            Button("async/await revoke") { Task.init { await asyncRevoke() } }
            Button("combine request") { combineReq() }
            Button("combine revoke") { combineRevoke() }
        }.buttonStyle(BlueButton())
    }
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
