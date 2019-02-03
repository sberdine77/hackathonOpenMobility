//
//  BikePEStations.swift
//  Atival
//
//  Created by Sávio Berdine on 03/02/19.
//  Copyright © 2019 Sávio Berdine. All rights reserved.
//

import MapKit

class BikePEStations: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var location: String?
    
    init(title: String, latitude: Double, longitude: Double, location: String) {
        self.title = title
        var coord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        coord.latitude = latitude
        coord.longitude = longitude
        self.coordinate = coord
        self.location = location
        super.init()
    }
    
    var subtitle: String? {
        return location
    }
    
}
