//
//  MapViewModel.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 12/6/25.
//

import SwiftUI
import FirebaseFirestore
import MapKit
import Combine

struct SavedLocation: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var dateAdded: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class MapViewModel: ObservableObject {
    @Published var savedLocations: [SavedLocation] = []
    private let db = Firestore.firestore()
    private var currentUserId: String?
    
    func initialize(userId: String?) {
        self.currentUserId = userId
        if userId != nil {
            fetchLocations()
        }
    }
    
    func fetchLocations() {
        guard let uid = currentUserId else { return }
        
        db.collection("users").document(uid).collection("saved_places")
            .order(by: "dateAdded", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.savedLocations = documents.compactMap { doc -> SavedLocation? in
                    try? doc.data(as: SavedLocation.self)
                }
            }
    }
    
    // Updated to accept address
    func saveLocation(name: String, address: String?, coordinate: CLLocationCoordinate2D) {
        guard let uid = currentUserId else { return }
        
        let newLocation = SavedLocation(
            id: nil,
            name: name,
            address: address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            dateAdded: Date()
        )
        
        do {
            try db.collection("users").document(uid).collection("saved_places").addDocument(from: newLocation)
        } catch {
            print("Error saving location: \(error)")
        }
    }
}
