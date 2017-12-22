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
    
    let directionPolyline = GMSPolyline()
    var bIsShowRoute = true

    var currentLocCoordinates = CLLocationCoordinate2D(latitude: 12.9503928, longitude: 77.5755419)
    
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
        
        let mumbaiLoc = CLLocationCoordinate2D(latitude: 19.089560, longitude: 72.865614)
        let chennaiLoc = CLLocationCoordinate2D(latitude: 12.994112, longitude: 80.170867)
        
        if bIsShowRoute
        {
            getPolylineRoute( from: mumbaiLoc, to: chennaiLoc)
        }

        // Create a GMSCameraPosition.
        let camera = GMSCameraPosition.camera(withLatitude: 12.917382, longitude: 77.578154, zoom: 9.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        
        //Current location with Green color marker.
        markerCurrentLocation.title = "Current"
        markerCurrentLocation.snippet = "Location"
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
        
        self.view = mapView
        
        if bIsShowRoute
        {
            directionPolyline.map = mapView
        }
    }
    
    //Display polyline route.
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        
                        DispatchQueue.global(qos: .background) .async {
                            
                        let array = json["routes"] as! NSArray
                        let dic = array[0] as! NSDictionary
                        let dic1 = dic["overview_polyline"] as! NSDictionary
                        let points = dic1["points"] as! String
                        
                        print(points)
                        
                            DispatchQueue.main.async {
                                
                                let pathway = GMSPath(fromEncodedPath: points)
                                
                                self.directionPolyline.path = pathway
                                
                                self.directionPolyline.strokeWidth = 2.0
                                self.directionPolyline.strokeColor = UIColor.cyan
                            }
                        }
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
  
    //Display Address.
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) -> String
    {
        var addressString : String = ""
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    print(addressString)
                }
        })
        return addressString
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        markerCurrentLocation.position = locations[0].coordinate

        currentLocCoordinates = locations[0].coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            //Load
            loadView()
        }
    }
}
