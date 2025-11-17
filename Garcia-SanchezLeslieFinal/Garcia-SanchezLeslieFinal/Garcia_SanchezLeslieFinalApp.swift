//
//  Garcia_SanchezLeslieFinalApp.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/15/25.
//

import SwiftUI

@main
struct KeepMePostedApp: App {
    var body: some Scene {
        WindowGroup {
            AuthFlowView()
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
