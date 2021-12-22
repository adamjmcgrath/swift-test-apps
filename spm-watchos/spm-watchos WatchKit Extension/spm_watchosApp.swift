//
//  spm_watchosApp.swift
//  spm-watchos WatchKit Extension
//
//  Created by Adam Mcgrath on 22/12/2021.
//

import SwiftUI

@main
struct spm_watchosApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
