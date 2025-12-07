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
import CoreLocation

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    private let db = Firestore.firestore()
    
    @Published var locationDisplayName: String = "Cupertino, California"
    @Published var locationCoordinate: CLLocationCoordinate2D?
    
    @Published var userFullName: String = ""
    
    init() {
        self.currentUser = Auth.auth().currentUser
        // If user is already logged in, fetch their data immediately
        if currentUser != nil {
            fetchUserData()
        }
    }
    
    func signUp(fullName: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
                return
            }
            guard let user = result?.user else { return }
            self?.currentUser = user
            
            // Create user document in Firestore
            let data: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "fullName": fullName,
                "dateCreated": Timestamp()
            ]
            
            self?.db.collection("users").document(user.uid).setData(data) { _ in
                completion(nil)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
                return
            }
            self?.currentUser = result?.user
            self?.fetchUserData()
            
            completion(nil)
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.currentUser = nil
        self.locationDisplayName = "Cupertino, California" // Reset to default
        self.locationCoordinate = nil
    }
    
    func saveLocation(name: String, coordinate: CLLocationCoordinate2D?) {
        guard let uid = currentUser?.uid else { return }
        
        // 1. Update Local State
        self.locationDisplayName = name
        self.locationCoordinate = coordinate
        
        // 2. Prepare Data for Firestore
        var data: [String: Any] = [
            "locationName": name
        ]
        
        if let coord = coordinate {
            data["locationLat"] = coord.latitude
            data["locationLng"] = coord.longitude
        }
        
        // 3. Write to Firestore
        db.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                print("Error saving location: \(error.localizedDescription)")
            } else {
                print("Location saved successfully to Firestore.")
            }
        }
    }
    
    func fetchUserData() {
        guard let uid = currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else { return }
            
            // Fetch Full Name
            if let fullName = data["fullName"] as? String {
                DispatchQueue.main.async {
                    self.userFullName = fullName
                }
            }
            
            // Fetch Location Name
            if let name = data["locationName"] as? String {
                DispatchQueue.main.async {
                    self.locationDisplayName = name
                }
            }
            
            // Fetch Coordinates
            if let lat = data["locationLat"] as? Double,
               let lng = data["locationLng"] as? Double {
                DispatchQueue.main.async {
                    self.locationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                }
            }
        }
    }
}
