//
//  LocationSearchViewModel.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/26/25.
//

import SwiftUI
import MapKit
import Combine

// This is to be upgraded to MapKit, GPT lead me astray here
class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    
    private var completer: MKLocalSearchCompleter
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            suggestions = []
            completer.queryFragment = ""
        } else {
            completer.queryFragment = trimmed
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }
    
    func selectLocation(_ suggestion: MKLocalSearchCompletion,
                        completion: @escaping (MKCoordinateRegion?) -> Void) {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let coordinate = response?.mapItems.first?.placemark.coordinate else {
                completion(nil)
                return
            }

            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
            
            DispatchQueue.main.async {
                self.selectedCoordinate = coordinate   // <— adds to firebase
                completion(region)
            }
        }
    }
}

