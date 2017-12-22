//
//  ViewController.swift
//  Task
//
//  Created by Yathiraj on 12/21/17.
//  Copyright © 2017 incendiary. All rights reserved.
//

import UIKit

import GoogleMaps
import CoreLocation

class locationViewController: UIViewController, CLLocationManagerDelegate
{
    let manager = CLLocationManager()
    
    // Creates markers in the map.
    let markerMumbaiAirport = GMSMarker()
    let markerCurrentLocation = GMSMarker()
    let markerChennaiAirport = GMSMarker()
    
    //Draw route polyline.
    let directionPolyline = GMSPolyline()
    
    //Flag to switch between routes.
    var bIsSwitchRoute = false
   
    //Location coordinates.
    var currentLocCoordinates = CLLocationCoordinate2D()
    let mumbaiLoc = CLLocationCoordinate2D(latitude: 19.089560, longitude: 72.865614)
    let chennaiLoc = CLLocationCoordinate2D(latitude: 12.994112, longitude: 80.170867)
    
    //Button 'Switch Route'.
    let btnSwitchRoute = UIButton()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Set button properties.
        btnSwitchRoute.frame = CGRect(x: 20,
                                      y: 50,
                                      width: 140,
                                      height: 44)   
        btnSwitchRoute.setTitle("Switch Route", for: .normal)
        btnSwitchRoute.backgroundColor = UIColor.blue
        btnSwitchRoute.setTitleColor(UIColor.white, for: .normal)
        btnSwitchRoute.setTitleColor(UIColor.white.withAlphaComponent(0.3),
                                         for: .highlighted)
        btnSwitchRoute.addTarget(self,
                                 action: #selector(btnSwitchAction),
                                 for: .touchUpInside)

        manager.delegate = self
        manager.requestAlwaysAuthorization()
        
        //Check Access and load map view.
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
    
    override func loadView()
    {
        // Create GMSCameraPosition.
        let camera = GMSCameraPosition.camera(withLatitude: 12.917382,
                                              longitude: 77.578154, zoom: 9.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        
        //Current location with 'Green' color marker.
        markerCurrentLocation.title = "Current Location"
        markerCurrentLocation.map = mapView
        markerCurrentLocation.icon = GMSMarker.markerImage(with: UIColor.green)
        
        //Mumbai Airport location with 'Red' color marker.
        markerMumbaiAirport.position = CLLocationCoordinate2D(latitude: 19.089560,
                                                              longitude: 72.865614)
        markerMumbaiAirport.title = "Shivaji International Airport"
        markerMumbaiAirport.snippet = " Ville Parle East, Mumbai, India, 400070"
        markerMumbaiAirport.map = mapView
        markerMumbaiAirport.icon = GMSMarker.markerImage(with: UIColor.red)

        //Chennai Airport location with 'Blue' color marker.
        markerChennaiAirport.position = CLLocationCoordinate2D(latitude: 12.994112,
                                                               longitude: 80.170867)
        markerChennaiAirport.title = "Chennai International Airport"
        markerChennaiAirport.snippet = "Minambakkam, Sholinganallur, India, 601213"
        markerChennaiAirport.map = mapView
        markerChennaiAirport.icon = GMSMarker.markerImage(with: UIColor.blue)
        
        self.view = mapView
        
        //Add button 'Switch Route as sub view to map view.
        mapView.addSubview(btnSwitchRoute)
        
        //Update direction polyline.
        directionPolyline.map = mapView
    }
    
    //Function to switch between routes.
    func btnSwitchAction()
    {
        bIsSwitchRoute = !(bIsSwitchRoute)
    }
    
    //Display polyline route.
    func getPolylineRoutes(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
    {
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
                            
                            DispatchQueue.main.async {
                                
                                let pathway = GMSPath(fromEncodedPath: points)
                                
                                self.directionPolyline.path = pathway
                                
                                self.directionPolyline.strokeWidth = 3.0
                                
                                if (self.bIsSwitchRoute)
                                {
                                    self.directionPolyline.strokeColor = UIColor.red
                                }
                                else
                                {
                                    self.directionPolyline.strokeColor = UIColor.blue
                                }
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
  
    //Display Coordinate Address.
    func getAddressFromLatLons(pdblLatitude: String, withLongitude pdblLongitude: String)
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
                    self.markerCurrentLocation.snippet = addressString
                }
        })
    }
  
    //Update current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       //Update current location marker.
        markerCurrentLocation.position = locations[0].coordinate
       
        //Update current location coordinates.
        currentLocCoordinates = locations[0].coordinate
       
        //Update current location address.
        getAddressFromLatLons(pdblLatitude: "\(locations[0].coordinate.latitude)",
            withLongitude: "\(locations[0].coordinate.longitude)" )
       
        //To switch routes.
        if bIsSwitchRoute
        {
            getPolylineRoutes( from: currentLocCoordinates, to: mumbaiLoc)
        }
        else
        {
            getPolylineRoutes( from: currentLocCoordinates, to: chennaiLoc)
        }
    }
    
    //AuthorizationStatus.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            //Load map view.
            loadView()
        }
    }
}


