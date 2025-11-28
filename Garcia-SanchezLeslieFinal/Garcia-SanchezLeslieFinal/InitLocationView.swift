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
    
    var body : some View {
//        Color.white.ignoresSafeArea()
        
        VStack(spacing: 24) {
            ZStack {
                HStack {
                    NavigationLink(destination: SignInView()) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.18, green: 0.44, blue: 0.63))
                
                    Spacer()
                    
                    NavigationLink(destination: HomeView()) {
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
            // map
            Map(coordinateRegion: $region)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            if !searchVM.suggestions.isEmpty {
//                let rowHeight: CGFloat = 56
//                let totalHeight = CGFloat(searchVM.suggestions.count) * rowHeight
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchVM.suggestions.indices, id: \.self) { index in
                            let suggestion = searchVM.suggestions[index]
                            
                            Button {
                                searchVM.selectLocation(suggestion) { newRegion in
                                    if let region = newRegion {
                                        self.region = region
                                    }
                                }
                                
                                // Fill the field with the chosen address
                                searchVM.searchQuery = suggestion.title + " " + suggestion.subtitle
                                
                                // Hide the list
                                searchVM.suggestions = []
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text(suggestion.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                            }
                            
                            if index != searchVM.suggestions.indices.last {
                                Divider()
                            }
                        }
                    }
                }
                .frame(
                    maxHeight: min(CGFloat(searchVM.suggestions.count) * 56, 250)
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 3)
                .padding(.horizontal, 32)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 24)
    
        
        VStack(spacing: 12) {
            Button(action: {
                let coord = searchVM.selectedCoordinate ?? region.center
                dismiss()
            }) {
                Text("Confirm Location")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.50, green: 0.69, blue: 0.73))
                    )
            }
            
            Button(action: {
                locationManager.requestCurrentLocation()
            }) {
                Text("Use My Current Location")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.28, green: 0.63, blue: 0.69))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.28, green: 0.63, blue: 0.69), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                    )
            }

        }
        .padding(.horizontal, 24)
        .ignoresSafeArea(.keyboard)
        .onReceive(locationManager.$currentCoordinate.compactMap { $0 }) { coord in
            region.center = coord
            searchVM.selectedCoordinate = coord   // <— so Confirm uses this
        }
        
        Spacer()
    }

}

#Preview {
    InitLocationView()
}
