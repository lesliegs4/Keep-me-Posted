//
//  InitLocationView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/24/25.
//

import SwiftUI
import MapKit
import Combine
import CoreLocation

struct InitLocationView : View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // LA example
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @StateObject private var searchVM = LocationSearchViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var navigateToHome = false
    @State private var isLoadingLocation = false
    
    var body : some View {
        
        VStack(spacing: 24) {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.18, green: 0.44, blue: 0.63))
                
                    Spacer()
                    
                    Button(action: {
                        authVM.locationDisplayName = "Cupertino, California"
                        authVM.locationCoordinate = nil
                        navigateToHome = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.gray)
                    }
                }
                
                VStack(spacing: 2) {
                    Text("Where are you joining")
                    Text("us from?")
                }
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 25)
            // SEARCH BAR
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for a place or address", text: $searchVM.searchQuery)
                    .onChange(of: searchVM.searchQuery) { newValue in
                        searchVM.search(query: newValue)
                    }
                
                
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.85, green: 0.89, blue: 0.93), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.99))
                    )
            )
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region).clipShape(RoundedRectangle(cornerRadius: 8))
            
            if !searchVM.suggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchVM.suggestions.indices, id: \.self) { index in
                            let suggestion = searchVM.suggestions[index]
                            Button {
                                searchVM.selectLocation(suggestion) { newRegion in
                                    if let region = newRegion { self.region = region }
                                }
                                // Use the title as the location name
                                searchVM.searchQuery = suggestion.title
                                searchVM.suggestions = []
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(suggestion.title).font(.system(size: 14, weight: .medium)).foregroundColor(.primary)
                                    Text(suggestion.subtitle).font(.system(size: 12)).foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                            }
                            if index != searchVM.suggestions.indices.last { Divider() }
                        }
                    }
                }
                .frame(maxHeight: 250)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                .padding(.horizontal, 32)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 24)
    
        
        VStack(spacing: 12) {
                    // Confirm Location
                    Button(action: {
                        let coord = searchVM.selectedCoordinate ?? region.center
                        // Use search query as name, or a fallback
                        let name = searchVM.searchQuery.isEmpty ? "Selected Location" : searchVM.searchQuery
                        
                        authVM.saveLocation(name: name, coordinate: coord)
                        navigateToHome = true
                    }) {
                        Text("Confirm Location")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.50, green: 0.69, blue: 0.73)))
                    }
                    
                    // Use Current Location
                    Button(action: {
                        locationManager.requestCurrentLocation()
                        // The actual logic triggers in .onReceive below
                    }) {
                        if isLoadingLocation {
                            ProgressView()
                        } else {
                            Text("Use My Current Location")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.28, green: 0.63, blue: 0.69))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.28, green: 0.63, blue: 0.69), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        
        Spacer()
        
        // Listener for Current Location
        .onReceive(locationManager.$currentCoordinate.compactMap { $0 }) { coord in
            // Stop repeated updates if we are already processing
            guard !isLoadingLocation else { return }
            isLoadingLocation = true
            
            region.center = coord
            
            // Reverse Geocode
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                isLoadingLocation = false
                
                if let place = placemarks?.first {
                    // Format: "Los Angeles, CA"
                    let city = place.locality ?? ""
                    let state = place.administrativeArea ?? ""
                    let displayName = city.isEmpty ? "Current Location" : "\(city), \(state)"
                    
                    authVM.saveLocation(name: displayName, coordinate: coord)
                    navigateToHome = true
                } else {
                    // Fallback if geocoding fails
                    authVM.saveLocation(name: "Current Location", coordinate: coord)
                    navigateToHome = true
                }
            }
        }
        
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .environmentObject(authVM)
                .navigationBarBackButtonHidden(true)
        }
    }

}

#Preview {
    InitLocationView()
}
