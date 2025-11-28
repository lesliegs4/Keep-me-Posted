//
//  AuthViewModel.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/17/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?   // FirebaseAuth.User
    let db = Firestore.firestore()
    
    init() {
        self.currentUser = Auth.auth().currentUser
    }
    
    func signUp(fullName: String,
                email: String,
                password: String,
                completion: @escaping (Error?) -> Void) {
        
//        print("Starting sign up...")
//        print("Email = \(email)")
//        print("Password length = \(password.count)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            
            if let error = error {
                print("Firebase Auth Error:")
                print("\(error.localizedDescription)")
                print("Error info: \(error)")
                
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                print("Error: Firebase returned nil user")
                completion(NSError(domain: "AuthVM", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is nil"]))
                return
            }
            
//            print("Firebase Auth created user:")
//            print("   UID: \(user.uid)")
//            print("   Email: \(user.email ?? "nil")")
            
            // Set display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            changeRequest.commitChanges { err in
                if let err = err {
                    print("Display name error: \(err.localizedDescription)")
                } else {
                    print("Display name saved.")
                }
            }
            
            // Save user to Firestore
            let data: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Timestamp()
            ]
            
            print("Writing user to Firestore...")
            
            self?.db.collection("users").document(user.uid).setData(data) { err in
                if let err = err {
                    print("Firebase error: \(err.localizedDescription)")
                } else {
                    print("Firestore write successful.")
                }
            }
            
            completion(nil)
        }
    }
    
    func signIn(email: String,
                password: String,
                completion: @escaping (Error?) -> Void) {
                
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            
            if let error = error {
                print("Firebase sign in error:")
                print("\(error.localizedDescription)")
                print("Full error: \(error)")
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                let err = NSError(domain: "AuthVM",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "User is nil after sign in"])
                print("Sign in error: \(err)")
                completion(err)
                return
            }
            
            // print("Sign in successful. UID=\(user.uid), email=\(user.email ?? "nil")")
            self?.currentUser = user
            completion(nil)
        }
    }

}
