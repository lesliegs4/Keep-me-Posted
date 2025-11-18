//
//  SignUpView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/16/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        
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
                        .stroke(Color(red: 0.80, green: 0.86, blue: 0.93), lineWidth: 1)
                )
            }
            
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .semibold))
                
                HStack {
                    TextField("", text: $email)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.80, green: 0.86, blue: 0.93), lineWidth: 1)
                )
            }
            
            // Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 14, weight: .semibold))
                
                HStack {
                    SecureField("Enter your password", text: $password)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.80, green: 0.86, blue: 0.93), lineWidth: 1)
                )
                
                Text("Password must be at least 6 characters, with one uppercase, one lowercase, one number, and one special character.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
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
    
    
    private func createAccount() {
        print("DEBUG: createAccount tapped")
        print("DEBUG: fullName = \(fullName)")
        print("DEBUG: email = \(email)")
        print("DEBUG: password length = \(password.count)")
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
                    // sign up was sucessful
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
