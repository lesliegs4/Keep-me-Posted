//
//  MapView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 12/6/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var mapVM = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    
    // MARK: - Map State
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // MARK: - UI State
    @State private var showNameDialog = false
    @State private var newLocationName = ""
    @State private var isSheetExpanded = false
    
    let collapsedHeight: CGFloat = 140
    let expandedHeight: CGFloat = 400
    
    var body: some View {
        ZStack {
            
            // 1. THE MAP (Base Layer)
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: mapVM.savedLocations) { location in
                
                MapAnnotation(coordinate: location.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                            .shadow(radius: 2)
                            .background(Circle().fill(Color.white)) // White backing for visibility
                        
                        Text(location.name)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white.opacity(0.85))
                            .cornerRadius(4)
                            .offset(y: 2)
                    }
                    // Offset the pin so the bottom point sits on the coordinate
                    .offset(y: -15)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                mapVM.initialize(userId: authVM.userId)
                if let userLoc = locationManager.currentCoordinate {
                    region.center = userLoc
                }
            }
            
            // 2. THE CENTER TARGET DOT
            // Exact Center of ZStack (matches region.center)
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .blur(radius: 3)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .shadow(radius: 2)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 16)
            }
            .allowsHitTesting(false) // Allows zooming/panning UNDER the dot
            
            // 3. UI LAYOUT (Buttons & Sheet)
            // Use a Vstack with a Spacer that allows touches through
            VStack(spacing: 0) {
                Spacer()
                    .allowsHitTesting(false) // CRITICAL: Lets touches pass to Map
                
                // Floating Buttons
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        
                        // Add Location (+) Button
                        Button(action: {
                            newLocationName = ""
                            showNameDialog = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.50, green: 0.69, blue: 0.73))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                
                // Draggable Sheet
                SavedPlacesSheet(
                    locations: mapVM.savedLocations,
                    isExpanded: $isSheetExpanded,
                    collapsedHeight: collapsedHeight,
                    expandedHeight: expandedHeight,
                    onSelectLocation: { coordinate in
                        withAnimation {
                            region.center = coordinate
                            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            isSheetExpanded = false
                        }
                    }
                )
            }
        }
        .alert("Pin Location", isPresented: $showNameDialog) {
            TextField("Location Name", text: $newLocationName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                saveLocationWithAddress()
            }
        } message: {
            Text("Create a pin at the center blue dot?")
        }
    }
    
    // Helper to get address before saving
    private func saveLocationWithAddress() {
        let center = region.center
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                // Construct address string: "Street, City" or "City, State"
                let street = place.thoroughfare ?? ""
                let city = place.locality ?? ""
                let state = place.administrativeArea ?? ""
                
                var addressString = ""
                if !street.isEmpty {
                    addressString = "\(street), \(city)"
                } else if !city.isEmpty {
                    addressString = "\(city), \(state)"
                } else {
                    addressString = "Unknown Address"
                }
                
                // Save with address
                mapVM.saveLocation(name: newLocationName, address: addressString, coordinate: center)
            } else {
                // Fallback if geocoding fails
                mapVM.saveLocation(name: newLocationName, address: "Pinned Location", coordinate: center)
            }
        }
    }
}

// MARK: - Bottom Sheet Component
struct SavedPlacesSheet: View {
    var locations: [SavedLocation]
    @Binding var isExpanded: Bool
    let collapsedHeight: CGFloat
    let expandedHeight: CGFloat
    var onSelectLocation: (CLLocationCoordinate2D) -> Void
    
    @GestureState private var dragTranslation: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                Text(isExpanded ? "Saved Locations" : "Swipe up for locations")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation { isExpanded.toggle() }
            }
            .gesture(
                DragGesture()
                    .updating($dragTranslation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.height < -threshold {
                            withAnimation { isExpanded = true }
                        } else if value.translation.height > threshold {
                            withAnimation { isExpanded = false }
                        }
                    }
            )
            
            // List Content
            if isExpanded {
                List {
                    if locations.isEmpty {
                        Text("No saved locations yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(locations) { loc in
                            Button(action: {
                                onSelectLocation(loc.coordinate)
                            }) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                    VStack(alignment: .leading) {
                                        Text(loc.name)
                                            .font(.body.bold())
                                            .foregroundColor(.primary)
                                        
                                        // SHOW ADDRESS HERE
                                        Text(loc.address ?? "Pinned Location")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            Spacer()
        }
        .frame(height: isExpanded ? expandedHeight : collapsedHeight)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
