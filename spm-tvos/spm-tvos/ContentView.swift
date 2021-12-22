//
//  ContentView.swift
//  spm-watchos WatchKit Extension
//
//  Created by Adam Mcgrath on 22/12/2021.
//

import SwiftUI
import Auth0

let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

func asyncAwait() async {
    do {
        let user = try await Auth0
            .users(token: "AT")
            .logging(enabled: true)
            .get("USER")
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
    var body: some View {
        VStack(spacing: 10) {
            Button("async/await request") { Task.init { await asyncAwait() } }
            Button("async/await revoke") { Task.init { await asyncRevoke() } }
        }
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
