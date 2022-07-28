//
//  AddressManager.swift
//  TravElite
//
//  Created by Manjot Dola on 2022-07-27.
//

import Foundation
import CoreLocation

struct Location {
    let title: String
    let coordinates: CLLocationCoordinate2D
}

class AddressManager: NSObject {
    static let shared = AddressManager()
    
    public func findAddresses(with query: String, completion: @escaping((([Location]) -> Void))) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            
            let models: [Location] = places.compactMap({ place in
                var name = ""
                
                if let locationName = place.name {
                    name += locationName
                }
                
                if let adminRegion = place.administrativeArea {
                    name += ", \(adminRegion)"
                }
                
                if let locality = place.locality {
                    name += ", \(locality)"
                }
                
                if let country = place.country {
                    name += ", \(country)"
                }
                                
                let result = Location(
                    title: name,
                    coordinates: place.location!.coordinate)
                
                return result
            })
            
            completion(models)
        }
    }
    
}
