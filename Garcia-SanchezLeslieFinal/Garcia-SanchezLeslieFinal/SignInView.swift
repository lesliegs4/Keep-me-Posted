//
//  SignInView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/15/25.
//
import SwiftUI

struct SignInView : View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    var body: some View {
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
                        SecureField("Enter your password", text: $password)
                            .font(.system(size: 15))
                        
                        Image(systemName: "eye")
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 40)
                
                Button(action: {}) {
                    Text("Sign In")
                        .font(.system(size:16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.50, green: 0.69, blue: 0.73))
                        )
                }
                .padding(.horizontal, 40)
                
                Text("or")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                VStack {
                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle")
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
                
                
            }
        }
    }
}

#Preview {
    SignInView()
}

