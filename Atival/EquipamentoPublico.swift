//
//  EquipamentoPublico.swift
//  Atival
//
//  Created by Sávio Berdine on 03/02/19.
//  Copyright © 2019 Sávio Berdine. All rights reserved.
//

import MapKit

class EquipamentoPublico: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    let locationName: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, locationName: String) {
        self.title = title
        self.coordinate = coordinate
        self.locationName = locationName
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}
