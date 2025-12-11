//
//  InitLocationView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/24/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct InitLocationView : View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @StateObject private var searchVM = LocationSearchViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var navigateToHome = false
    @State private var isLoadingLocation = false
    
    // This did not work so will probably update this flag
    @State private var isQueryUpdateProgrammatic = false
    
    var body : some View {
        VStack(spacing: 24) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.18, green: 0.44, blue: 0.63))
                
                    Spacer()
                    
                    Button(action: {
                        authVM.saveLocation(name: "Cupertino, California", coordinate: nil)
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
            
            // MARK: Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search for a place or address", text: $searchVM.searchQuery)
                    .onChange(of: searchVM.searchQuery) { newValue in
                        // Progamatic query isn't responsive
                        if !isQueryUpdateProgrammatic {
                            searchVM.search(query: newValue)
                        }
                    }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.85, green: 0.89, blue: 0.93), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        
        // MARK: Map & Suggestions List
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region).clipShape(RoundedRectangle(cornerRadius: 8))
            
            if !searchVM.suggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchVM.suggestions.indices, id: \.self) { index in
                            let suggestion = searchVM.suggestions[index]
                            Button {
                                isQueryUpdateProgrammatic = true
                            
                                searchVM.selectLocation(suggestion) { newRegion in
                                    if let newRegion = newRegion {
                                        withAnimation {
                                            self.region = newRegion
                                        }
                                    }
                                }
                                
                                // Update text and clear list
                                searchVM.searchQuery = suggestion.title
                                searchVM.suggestions = []
                                
                                // Reset flag asynchronously to ensure UI updates finish
                                DispatchQueue.main.async {
                                    isQueryUpdateProgrammatic = false
                                }
                                
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(suggestion.title).font(.system(size: 14, weight: .medium)).foregroundColor(.primary)
                                    Text(suggestion.subtitle).font(.system(size: 12)).foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .leading) // Ensure full width tap area
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
    
        // Bottom Buttons
        VStack(spacing: 12) {
            Button(action: {
                let coord = searchVM.selectedCoordinate ?? region.center
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
            
            Button(action: {
                isLoadingLocation = false
                locationManager.requestCurrentLocation()
                
                if let currentLoc = locationManager.currentCoordinate {
                    withAnimation {
                        region.center = currentLoc
                        region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    }
                }
                
            }) {
                if isLoadingLocation {
                    ProgressView()
                        .padding(.vertical, 12)
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
        .onReceive(locationManager.$currentCoordinate.compactMap { $0 }) { coord in
            
            // Move Map Immediately
            withAnimation {
                region.center = coord
                // Might omit this for Init should only be do-able in MapView
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            }
            
            // Perform Geocoding only if we aren't already working on it
            guard !isLoadingLocation else { return }
            isLoadingLocation = true
            
            let geocoder = CLGeocoder() // Will switch to using MapKit in the actual map bc this was too hard
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                isLoadingLocation = false
                
                if let place = placemarks?.first {
                    let city = place.locality ?? ""
                    let state = place.administrativeArea ?? ""
                    let displayName = city.isEmpty ? "Current Location" : "\(city), \(state)"
                    
                    authVM.saveLocation(name: displayName, coordinate: coord)
                    navigateToHome = true
                } else {
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
        .onChange(of: authVM.currentUser) { user in
            // If user logs out (becomes nil), dismiss this view too
            if user == nil {
                dismiss()
            }
        }
    }
}
