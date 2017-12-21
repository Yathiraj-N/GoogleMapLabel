//
//  ViewController.swift
//  Task
//
//  Created by Yathiraj on 12/21/17.
//  Copyright © 2017 incendiary. All rights reserved.
//

import UIKit

import GoogleMaps
import MapKit
import CoreLocation

class locationViewController: UIViewController, CLLocationManagerDelegate
{
    let manager = CLLocationManager()
    
    // Creates a marker in the center of the map.
    let markerMumbaiAirport = GMSMarker()
    let markerCurrentLocation = GMSMarker()
    let markerChennaiAirport = GMSMarker()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                loadView()
                print("Access")
            }
        }
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 12.917382, longitude: 77.578154, zoom: 9.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        
        //Current location with Green color marker.
        markerCurrentLocation.title = "Current"
        markerCurrentLocation.snippet = "Location"
        markerCurrentLocation.position = CLLocationCoordinate2D(latitude: 12.871590, longitude: 77.596059)
        markerCurrentLocation.map = mapView
        markerCurrentLocation.icon = GMSMarker.markerImage(with: UIColor.green)
        
        //Mumbai Airport marker. - RED color
        markerMumbaiAirport.position = CLLocationCoordinate2D(latitude: 19.089560, longitude: 72.865614)
        markerMumbaiAirport.title = "Mumbai"
        markerMumbaiAirport.snippet = "India"
        markerMumbaiAirport.map = mapView
        markerMumbaiAirport.icon = GMSMarker.markerImage(with: UIColor.red)

        //Chennai Airport markwer. - BLUE color
        markerChennaiAirport.position = CLLocationCoordinate2D(latitude: 12.994112, longitude: 80.170867)
        markerChennaiAirport.title = "Chennai"
        markerChennaiAirport.snippet = "India"
        markerChennaiAirport.map = mapView
        markerChennaiAirport.icon = GMSMarker.markerImage(with: UIColor.blue)
        
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: 19.089560, longitude: 72.865614))
        path.add(CLLocationCoordinate2D(latitude: 12.994112, longitude: 80.170867))

        let polylineRectangle = GMSPolyline(path: path)
        polylineRectangle.strokeWidth = 2.0
        polylineRectangle.map = mapView
        self.view = mapView
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        markerCurrentLocation.position = locations[0].coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            //Load
            loadView()

        }
    }
}
