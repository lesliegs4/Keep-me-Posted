//
//  SignInView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/15/25.
//
import SwiftUI

struct SignInView : View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var navigateToInitLocation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Rectangle() // placeholder for logo or image
                        .fill(Color.gray.opacity(0.15))
                        .frame(width:80, height: 80)
                        .cornerRadius(12)
                        .padding(.top, 40)
                    
                    Text("Welcome Back!")
                        .font(.title2.bold())
                    
                    Text("Please sign in to continue.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address") // Email field
                            .font(.system(size: 14, weight: .semibold))
                        
                        HStack {
                            TextField("Enter your email address", text: $email)
                                .font(.system(size: 16))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        Text("Password") // Password field
                            .font(.system(size: 14, weight: .semibold))
                        
                        HStack {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                                    .font(.system(size: 16))
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .font(.system(size: 16))
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Sign In")
                                .font(.system(size:16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.50, green: 0.69, blue: 0.73))
                    )
                    .padding(.horizontal, 40)
                    
                    Text("or")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    VStack {
                        Button(action: {}) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                Text("Continue with Google")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.15)))
                            )
                        }
                        
                        
                        Button(action: {}) {
                            HStack(spacing: 12) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                Text("Continue with Apple")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.darkGray))
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    HStack(spacing: 4) {
                        Spacer()
                        Text("Don't have an account?")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        
                        Button(action: {}) {
                            Text("Sign Up")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: InitLocationView()
                        .environmentObject(authVM),
                    isActive: $navigateToInitLocation
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
    
    private func signIn() {
            errorMessage = nil
            
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter email and password."
                return
            }
            
            isLoading = true
            authVM.signIn(email: email, password: password) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("DEBUG: signIn returned error: \(error)")
                        self.errorMessage = error.localizedDescription
                    } else {
                        print("DEBUG: signIn success, dismissing SignInView")
                        // For now, just dismiss back to previous screen.
                        // Later you can navigate to your main TabView.
                        self.navigateToInitLocation = true
                    }
                }
            }
        }
}

#Preview {
    SignInView()
}

