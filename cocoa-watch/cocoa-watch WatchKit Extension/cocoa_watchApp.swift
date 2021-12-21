//
//  cocoa_watchApp.swift
//  cocoa-watch WatchKit Extension
//
//  Created by Adam Mcgrath on 21/12/2021.
//

import SwiftUI

@main
struct cocoa_watchApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
