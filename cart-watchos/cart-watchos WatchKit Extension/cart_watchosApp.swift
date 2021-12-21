//
//  cart_watchosApp.swift
//  cart-watchos WatchKit Extension
//
//  Created by Adam Mcgrath on 21/12/2021.
//

import SwiftUI

@main
struct cart_watchosApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
