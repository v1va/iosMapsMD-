//
//  ViewController.swift
//  maps_md3
//
//  Created by viva brolite on 09/06/2020.
//  Copyright © 2020 vivabrolite. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase

class ViewController: UIViewController{

    @IBOutlet weak var textFieldAdress: UITextField!
    @IBOutlet weak var buttonDirections: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var favLocations = [FavLocation]()
   
    
    // MARK: - Get data from Firebase DB
    func fetchData(){
        
        do{
            ref = Database.database().reference().child("Locations")
            ref.observe(DataEventType.value, with: { (snap) in

                var title: String
                var locationName: String
                var coordinate: CLLocationCoordinate2D
                
                for child in snap.children.allObjects as! [DataSnapshot]{
                    
                    if let unwrappedTitle = child.childSnapshot(forPath: "title").value as? String{
                        title = unwrappedTitle
                    } else {
                        title = "Unknown"
                    }
                    

                    if let unwrappedLocationName = child.childSnapshot(forPath: "locationName").value as? String {
                        locationName = unwrappedLocationName
                    } else {
                        locationName = "Unknown Street Name"
                    }

                    
                    let lat = (child.childSnapshot(forPath: "latitude").value as! NSString).doubleValue
                    let long = (child.childSnapshot(forPath: "longitude").value as! NSString).doubleValue
                    coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let location = FavLocation(title: title, locationName: locationName, coordinate: coordinate)
                    //self.favLocations.append(location)
                    self.mapView.addAnnotation(location)
                }
            })
            
        } catch{
            print("It empty")
        }
            }
    
    
    
   
   override func viewDidLoad() {
       super.viewDidLoad()
    
       //let initialLocation = CLLocation(latitude: 37.769122, longitude: -122.428353)
        let initialLocation = CLLocation(latitude: 57.538610, longitude: 25.423788)
        zoomMapOn(location: initialLocation)
       
        mapView.delegate = self
        fetchData()
        //mapView.addAnnotations(favLocations)
   }
   
   override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       
       checkLocationServiceAuthenticationStatus()
   }
   
    // The region radius of zoom
    private let regionRadius: CLLocationDistance = 3000 
    
    func zoomMapOn(location: CLLocation){
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
    }
   
   // MARK: - Current Location
   
   var locationManager = CLLocationManager()
   
   func checkLocationServiceAuthenticationStatus()
   {
       locationManager.delegate = self
       if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
           mapView.showsUserLocation = true
           locationManager.startUpdatingLocation()
       } else {
           locationManager.requestWhenInUseAuthorization()
           locationManager.startUpdatingLocation()
       }
   }
   
   // MARK: - Show Direction
   
   var currentPlacemark: CLPlacemark?
   
   @IBAction func showDirection(sender: Any)
   {
       guard let currentPlacemark = currentPlacemark else {
           return
       }
       
    let directionRequest = MKDirections.Request()
       let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
       
       directionRequest.source = MKMapItem.forCurrentLocation()
       directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
       directionRequest.transportType = .automobile
       
       // calculate the directions / route
       let directions = MKDirections(request: directionRequest)
       directions.calculate { (directionsResponse, error) in
           guard let directionsResponse = directionsResponse else {
               if let error = error {
                   print("error getting directions: \(error.localizedDescription)")
               }
               return
           }
           
           let route = directionsResponse.routes[0]
           self.mapView.removeOverlays(self.mapView.overlays)
           self.mapView.addOverlay(route.polyline, level: .aboveRoads)
           
           let routeRect = route.polyline.boundingMapRect
           self.mapView.setRegion(MKCoordinateRegion(routeRect), animated: true)
       }
   }
    
    
    @IBAction func getDirectionsTapped(_ sender: Any) {
        
        guard let currentPlacemark = currentPlacemark else {
                  return
              }
              
           let directionRequest = MKDirections.Request()
              let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
              
              directionRequest.source = MKMapItem.forCurrentLocation()
              directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
              directionRequest.transportType = .automobile
              
              // calculate the directions / route
              let directions = MKDirections(request: directionRequest)
              directions.calculate { (directionsResponse, error) in
                  guard let directionsResponse = directionsResponse else {
                      if let error = error {
                          print("error getting directions: \(error.localizedDescription)")
                      }
                      return
                  }
                  
                  let route = directionsResponse.routes[0]
                  self.mapView.removeOverlays(self.mapView.overlays)
                  self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                  
                  let routeRect = route.polyline.boundingMapRect
                  self.mapView.setRegion(MKCoordinateRegion(routeRect), animated: true)
              }
        
    }
    
    
}


extension ViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        self.mapView.showsUserLocation = true
        zoomMapOn(location: location)
    }
}

extension ViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? FavLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let location = view.annotation as? FavLocation {
            self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 4.0
        
        return renderer
    }
}
