//
//  WelcomeView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/15/25.
//
import SwiftUI

struct WelcomeView : View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack (spacing: 12) {
                Text("Keep me Posted")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("For your travels and adventures")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            
            NavigationLink {
                SignInView()
            } label: {
                Text("Sign In")
                    .padding()
                    .background(Color(red: 0.50, green: 0.69, blue: 0.73))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
            
            NavigationLink {
                SignUpView()
            } label: {
                Text("Sign Up")
                    .font(.subheadline)
                    .padding(.top, 16)
            }
            Spacer()
        }
    }
}


#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
