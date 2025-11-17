//
//  Garcia_SanchezLeslieFinalApp.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/15/25.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct KeepMePostedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            AuthFlowView()
                .environmentObject(authViewModel)
        }
    }
}

struct AuthFlowView: View {
    var body: some View {
        NavigationStack {
            WelcomeView()
        }
    }
}
