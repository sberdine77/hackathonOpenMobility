//
//  ViewController.swift
//  Atival
//
//  Created by Sávio Berdine on 03/02/19.
//  Copyright © 2019 Sávio Berdine. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slider: UISlider!
    var locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        let initialLocation = CLLocation(latitude: 71.282778, longitude: 127.829444)
        centerMapOnLocation(location: initialLocation)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        Model.requestBikePEStations(onSuccess: { (stations) in
            print(stations)
        }) { (error) in
            print(error)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {return}
        self.locationManager.stopUpdatingLocation() //Retirar se quisermos atualizações em tempo real
        let currentLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
        centerMapOnLocation(location: currentLocation)
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

