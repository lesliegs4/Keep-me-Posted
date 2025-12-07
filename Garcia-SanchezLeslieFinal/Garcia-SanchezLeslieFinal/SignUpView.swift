//
//  SignUpView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/16/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    // Note: We don't need dismiss here since we are moving forward to InitLocation
    // @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 1. State to control navigation
    @State private var navigateToInitLocation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Create Your Account")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Let us help keep you Posted")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 20) {
                // Full Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack {
                        TextField("", text: $fullName)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack {
                        TextField("", text: $email)
                            .font(.system(size: 16))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack {
                        SecureField("", text: $password)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 13))
                    .padding(.top, 8)
                    .padding(.horizontal, 32)
            }
            
            Button(action: createAccount) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Create Account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.50, green: 0.69, blue: 0.73))
            )
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            Text("Already have an account?")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 16)
                .padding(.bottom, 40)
        }
        // MARK: - Navigation Destination
        // This MUST be attached to the ScrollView (or the outermost view inside `body`),
        // NOT after the closing brace of `body`.
        .navigationDestination(isPresented: $navigateToInitLocation) {
            InitLocationView()
                .environmentObject(authVM)
                .navigationBarBackButtonHidden(true) // Prevent going back to SignUp
        }
    } // End of body
    
    private func createAccount() {
        errorMessage = nil
        
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        authVM.signUp(fullName: fullName, email: email, password: password) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    // Success: Trigger navigation
                    self.navigateToInitLocation = true
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
