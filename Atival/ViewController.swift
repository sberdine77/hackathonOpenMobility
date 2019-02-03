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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var hora: UILabel!
    @IBOutlet weak var preco: UILabel!
    
    
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var polyline = MKPolyline()
    var distance = CLLocationDistance()
    var choosenDestination: CLLocation!
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        let initialLocation = CLLocation(latitude: 71.282778, longitude: 127.829444)
        centerMapOnLocation(location: initialLocation)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.activityType = .otherNavigation
            locationManager.startUpdatingLocation()
        }
        
        Model.requestBikePEStations(onSuccess: { (stations) in
            self.mapView.addAnnotations(stations)
        }) { (error) in
            print(error)
        }
        
        let an1 = BikePEStations(title: "Feirinha do Bom Jesus", latitude: -8.060997, longitude: -34.871992, location: "Rua do Bom Jesus")
        
        let an2 = BikePEStations(title: "Festa Calidus", latitude: -8.079193, longitude: -34.915426, location: "Calidus Dancing Bar")
        let an3 = BikePEStations(title: "Maracatu Quebra Baque", latitude: -8.064273, longitude: -34.873059, location: "Calidus Dancing Bar")
        
        self.mapView.addAnnotations([an1, an2, an3])
        
        sliderChanged(sender: self)
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .otherNavigation
        //locationManager.startUpdatingLocation()
        return true
    }
    
    func drawnMap(sourceMapItem: MKMapItem, destinationMapItem: MKMapItem) {

        mapView.removeOverlay(polyline)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.polyline = route.polyline
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if CLLocationManager.authorizationStatus() == .authorizedAlways {
//            locationManager.allowsBackgroundLocationUpdates = true
//        }
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {return}
        self.locationManager.stopUpdatingLocation() //Retirar se quisermos atualizações em tempo real
        self.currentLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
        centerMapOnLocation(location: currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("FOUND: " + identifier)
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
   
    @IBAction func sliderChanged(sender: AnyObject) {
        let miles = Double(self.slider.value)
        let delta = miles / 69.0
        
        var currentRegion = self.mapView.region
        currentRegion.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        self.mapView.region = currentRegion
        
//        travelRadius.text = "\(Int(round(miles))) miles"
//        
//        let (lat, long) = (currentRegion.center.latitude, currentRegion.center.longitude)
//        currentLocationLabel.text = "Current location: \(lat), \(long))"
    }
    
}

extension ViewController {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? BikePEStations else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! BikePEStations
        //let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        let myMapItem = MKMapItem.forCurrentLocation()
        
        if let destLoc = location.mapItem().placemark.location {
            print("OI")
            choosenDestination = destLoc
            distance = destLoc.distance(from: currentLocation)
            print(view.annotation?.title)
            self.titulo.text = view.annotation?.title ?? "None"
            print(distance)
        }
        
        
        drawnMap(sourceMapItem: myMapItem, destinationMapItem: location.mapItem())
        
        //let button = UIButton(frame: CGRect(x: slider.layer.position.x, y: slider.layer.position.y, width: 100, height: 50))
        let button = UIButton(frame: CGRect(origin: slider.frame.origin, size: CGSize(width: slider.frame.width, height: 50)))
        let color: UIColor = UIColor(red: 58/255, green: 204/255, blue: 225/255, alpha: 1)
        button.backgroundColor = color
        button.setTitle("Caminhar até o ponto", for: [])
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.slider.isHidden = true
        self.customView.addSubview(button)
        //location.mapItem()
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
        if choosenDestination != nil {
            self.monitorRegionAtLocation(center: CLLocationCoordinate2D(latitude: choosenDestination.coordinate.latitude, longitude: choosenDestination.coordinate.longitude), identifier: "")
            locationManager.startUpdatingLocation()
        }
        
        let alert = UIAlertController(title: "Começou!", message: "Aproveite a sua caminhada", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the app is authorized.
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            // Make sure region monitoring is supported.
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                // Register the region.
                let maxDistance = 156.0
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
}

