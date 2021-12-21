//
//  ContentView.swift
//  Shared
//
//  Created by Adam Mcgrath on 16/12/2021.
//

import Foundation
import SwiftUI
import Combine
import Auth0

let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

func login() {
    Auth0.webAuth()
        .audience("https://adam-spa-test.us.auth0.com/api/v2/")
        .scope("openid profile email offline_access read:current_user read:current_user_metadata")
        .logging(enabled: true)
        .start { result in
            switch result {
            case .success(let credentials):
                print(credentials)
                _ = credentialsManager.store(credentials: credentials)
            case .failure(let error): print(error)
            }
        }
}

func creds() {
// MASTER
//    credentialsManager.credentials() { error, credentials in
//        guard error == nil, let credentials = credentials else {
//            group.leave()
//            return print("Failed with \(error)")
//        }
//        group.leave()
//        print("\(i). Got credentials: \(credentials)")
//    }
// BETA
    credentialsManager.credentials { result in
        switch result {
        case .success(let credentials):
            print("Got credentials: \(credentials)")
        case .failure(let error):
            print("Failed with \(error)")
        }
    }
}

func credsAsync() async {
    do {
        let credentials = try await credentialsManager.credentials()
        print("Obtained credentials: \(credentials)")
    } catch {
        print("Failed with \(error)")
    }
}


func concurrentRefresh() {
    let group = DispatchGroup()
    for i in 0...5 {
        group.enter()
// MASTER
//        credentialsManager.credentials(minTTL: 86399) { error, credentials in
//            guard error == nil, let credentials = credentials else {
//                group.leave()
//                return print("Failed with \(error)")
//            }
//            group.leave()
//            print("\(i). Got credentials: \(credentials)")
//        }
// BETA
        credentialsManager.credentials(minTTL: 86399) { result in
            switch result {
            case .success(let credentials):
                print("\(i). Got credentials: \(credentials)")
                group.leave()
            case .failure(let error):
                print("Failed with \(error)")
                group.leave()
            }
        }
    }
}


func asyncAwait() async {
    do {
        let credentials = try await credentialsManager.credentials()
        let user = try await Auth0
            .users(token: credentials.accessToken)
            .logging(enabled: true)
            .get(credentialsManager.user!.sub)
            .start()
        print("User with metadata: \(user)")
    } catch {
        print("Failed with \(error)")
    }
}

func asyncLogin() async {
    Task.init { @MainActor in
        do {
            let credentials = try await Auth0.webAuth()
                .audience("https://adam-spa-test.us.auth0.com/api/v2/")
                .scope("openid profile email offline_access read:current_user read:current_user_metadata")
                .logging(enabled: true)
                .start()
            print("Logged in with: \(credentials)")
        } catch {
            print("Failed with \(error)")
        }
    }
}


func asyncClear() async {
    Task.init { @MainActor in
        do {
            try await Auth0
                .webAuth()
                .clearSession()
            print("Logged out")
        } catch {
            print("Failed with \(error)")
        }
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
    
    func combineReq() async {
        do {
            let credentials = try await credentialsManager.credentials()
            Auth0
                .users(token: credentials.accessToken)
                .logging(enabled: true)
                .get(credentialsManager.user!.sub)
                .publisher()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed with \(error)")
                    }
                }, receiveValue: { user in
                    print("User with metadata: \(user)")
                }).store(in: &cancellables)
        } catch {
            print("Failed to get creds \(error)")
        }
    }
    
    func combineLogin() {
        Auth0
            .webAuth()
            .publisher()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed with \(error)")
                }
            }, receiveValue: { credentials in
                print("Obtained credentials: \(credentials)")
            })
            .store(in: &cancellables)
    }
    
    func combineClear() {
        Auth0
            .webAuth()
            .clearSession()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed with \(error)")
                case .finished:
                    print("Logged out")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func combineCreds() {
        credentialsManager
            .credentials()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed with \(error)")
                }
            }, receiveValue: { credentials in
                print("Obtained credentials: \(credentials)")
            })
            .store(in: &cancellables)
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
        ScrollView {
            VStack(spacing: 10) {
                Group {
                    Button("Login") { login() }
                    Button("Get credentials") { creds() }
                    Button("concurrency test") { concurrentRefresh() }
                    Button("async/await request") { Task.init { await asyncAwait() } }
                    Button("async/await login") { Task.init { await asyncLogin() } }
                    Button("async/await clear") { Task.init { await asyncClear() } }
                    Button("async/await credentials") { Task.init { await credsAsync() } }
                    Button("async/await revoke") { Task.init { await asyncRevoke() } }
                    Button("combine request") { Task.init { await combineReq() } }
                    Button("combine login") { combineLogin() }
                }
                Group {
                    Button("combine get creds") { combineCreds() }
                    Button("combine clear creds") { combineClear() }
                    Button("combine revoke creds") { combineRevoke() }
                }
            }.buttonStyle(BlueButton())
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


