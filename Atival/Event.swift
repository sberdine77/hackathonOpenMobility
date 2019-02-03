//
//  Event.swift
//  Atival
//
//  Created by Sávio Berdine on 03/02/19.
//  Copyright © 2019 Sávio Berdine. All rights reserved.
//

import MapKit

class Event: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    let time: Int
    let isPaid: Bool
    let locationName: String
    
    init(title: String, time: Int, isPaid: Bool, coordinate: CLLocationCoordinate2D, locationName: String) {
        self.title = title
        self.time = time
        self.isPaid = isPaid
        self.coordinate = coordinate
        self.locationName = locationName
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}
