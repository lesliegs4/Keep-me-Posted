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
        
        print("DEBUG: Starting sign up...")
        print("DEBUG: Email = \(email)")
        print("DEBUG: Password length = \(password.count)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            
            if let error = error {
                print("🔥 FIREBASE AUTH ERROR:")
                print("🔥 \(error.localizedDescription)")
                print("🔥 Error info: \(error)")
                
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                print("🔥 ERROR: Firebase returned nil user")
                completion(NSError(domain: "AuthVM", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is nil"]))
                return
            }
            
            print("✅ Firebase Auth created user:")
            print("   UID: \(user.uid)")
            print("   Email: \(user.email ?? "nil")")
            
            // Set display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            changeRequest.commitChanges { err in
                if let err = err {
                    print("⚠️ Display name error: \(err.localizedDescription)")
                } else {
                    print("✅ Display name saved.")
                }
            }
            
            // Save user to Firestore
            let data: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Timestamp()
            ]
            
            print("DEBUG: Writing user to Firestore...")
            
            self?.db.collection("users").document(user.uid).setData(data) { err in
                if let err = err {
                    print("🔥 FIRESTORE ERROR: \(err.localizedDescription)")
                } else {
                    print("✅ Firestore write successful.")
                }
            }
            
            completion(nil)
        }
    }


}
