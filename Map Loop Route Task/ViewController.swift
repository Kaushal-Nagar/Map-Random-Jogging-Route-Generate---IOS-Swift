//
//  ViewController.swift
//  Map Loop Route Task
//
//  Created by webcodegenie on 14/06/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var TfInputField: UITextField!
    @IBOutlet weak var SegmentOutlet: UISegmentedControl!
    @IBOutlet weak var MvMapView: MKMapView!
    
    var myRoute : MKRoute?
    var locationManager : CLLocationManager!
    var CoordinatesArr: [CLLocationCoordinate2D] = []
    var AngleArr = [90,90,90,90]
    //HI Demo Comment Add for Github
    
    var CurrentLatitude : CLLocationDegrees = 0
    var CurrentLongitude : CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MvMapView.delegate = self
        SetUpLocationMAnager()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SetUI()
    }
    
    //MARK: - All IBActions
    
    @IBAction func OnClickGenerateRoute(_ sender: Any) {
        
        let InputValue = Int(TfInputField.text ?? "") ?? 0
        
        if ( SegmentOutlet.selectedSegmentIndex == 0 && InputValue < 25 ){
            ShowAlertBox(Title: "The Minutes should be more that 25 Minute.", Message: "")
        }
        else if( SegmentOutlet.selectedSegmentIndex == 1 && InputValue < 2 ){
            ShowAlertBox(Title: "The Kilo Meters should be more than 2 Kilo Meters.", Message: "")
        }
        else{
//            angle = 0
            CoordinatesArr = []
            CurrentLatitude = MvMapView.userLocation.coordinate.latitude
            CurrentLongitude = MvMapView.userLocation.coordinate.longitude
            
            generateRoute()
            
            for coordinate in CoordinatesArr{
                print(coordinate.latitude , coordinate.longitude)
            }
        }
    }
    
    
    @IBAction func OnClickDoActionWhileChangingSegment(_ sender: Any) {
        TfInputField.text = ""
        
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            TfInputField.placeholder = "Please Enter Time in Minutes( > 25 )"
        }
        else{
            TfInputField.placeholder = "Please Enter Distance in KiloMeters ( > 2 )"
        }
        
    }
    
    //MARK: - All Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        CurrentLatitude = locValue.latitude
        CurrentLongitude = locValue.longitude
        
        locationManager.stopUpdatingLocation()
        
        self.MvMapView.showsUserLocation = true
        
        // Init the zoom level
        let region = MKCoordinateRegion(center: locValue, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        self.MvMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\nError :", error)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 1.0
        renderer.lineDashPattern = [2,5]
        return renderer
    }
    
    //MARK: - All Defined Functions
    
    func generateRoute() {
        // Dismiss keyboard if it's still visible
        view.endEditing(true)
        
        // Get user input
        if let userInput = TfInputField.text, let value = Double(userInput) {
            var distance: Double = 0.0
            
            // Determine distance based on selected segment (0: time, 1: distance)
            if SegmentOutlet.selectedSegmentIndex == 0 {
                // Calculate distance for given time (assuming average walking speed of 5 km/h)
                let speedKmph = 5.0
                let timeInMinutes = value
                distance = (speedKmph / 60.0) * timeInMinutes
            } else {
                // Use directly input distance in kilometers
                distance = value
            }
            
            // Create circular path
            print("\nDistance in Before Deviding :",distance)
            distance = distance/6
            print("\nDistance in After Deviding:",distance,"\n")
            
            CoordinatesArr.append(MvMapView.userLocation.coordinate)
            for i in 0...3{
                moveToLocation(location: CLLocationCoordinate2D(latitude: CurrentLatitude, longitude: CurrentLongitude), distance: distance, Angle: Double(AngleArr[i]))
            }
            CoordinatesArr.append(MvMapView.userLocation.coordinate)
            
            MvMapView.removeOverlays(self.MvMapView.overlays)
            
            print("\nUser Current Location :", MvMapView.userLocation.coordinate)
            for CoordinateIndex in 0...CoordinatesArr.count-2{
                
                print(CoordinatesArr[CoordinateIndex].latitude , CoordinatesArr[CoordinateIndex].longitude)
                
                showRouteOnMap(pickupCoordinate: CoordinatesArr[CoordinateIndex], destinationCoordinate: CoordinatesArr[CoordinateIndex + 1])
            }
            
            MvMapView.setRegion(MKCoordinateRegion(center: MvMapView.userLocation.coordinate, latitudinalMeters: distance*10000, longitudinalMeters: distance*10000), animated: true)
            
            CoordinatesArr = []
            
        } else {
            // Handle invalid input
            ShowAlertBox(Title: "Please enter a valid number.", Message: "")
        }
    }
    
    
    
    func moveToLocation(location: CLLocationCoordinate2D, distance: Double, Angle: Double) {
        
        let CurrentLocation = CLLocationCoordinate2D(latitude: CurrentLatitude, longitude: CurrentLongitude)
        
        let newLocation = self.coordinates(startingCoordinates: location, atDistance: distance, atAngle: Angle)
        
//        angle = 36
        
        CurrentLatitude = newLocation.latitude
        CurrentLongitude = newLocation.longitude
        
        CoordinatesArr.append(newLocation)
        
    }
    
    func coordinates(startingCoordinates: CLLocationCoordinate2D, atDistance: Double, atAngle: Double) -> CLLocationCoordinate2D {
        
        let distanceRadians = atDistance / 6371
        let bearingRadians = self.degreesToRadians(x: atAngle)
        let fromLatRadians = self.degreesToRadians(x: startingCoordinates.latitude)
        let fromLonRadians = self.degreesToRadians(x: startingCoordinates.longitude)
        
        let toLatRadians = asin(sin(fromLatRadians) * cos(distanceRadians) + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians))
        var toLonRadians = fromLonRadians + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians) - sin(fromLatRadians) * sin(toLatRadians));
        
        toLonRadians = fmod((toLonRadians + 3 * .pi), (2 * .pi)) - .pi
        
        let lat = self.radiansToDegrees(x: toLatRadians)
        let lon = self.radiansToDegrees(x: toLonRadians)
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
//    func calculateAngleBetweenLocations(currentLocation: CLLocationCoordinate2D, targetLocation: CLLocationCoordinate2D) -> Double {
//        let fLat = self.degreesToRadians(x: currentLocation.latitude);
//        let fLng = self.degreesToRadians(x: currentLocation.longitude);
//        let tLat = self.degreesToRadians(x: targetLocation.latitude);
//        let tLng = self.degreesToRadians(x: targetLocation.longitude);
//        let deltaLng = tLng - fLng
//
//        let y = sin(deltaLng) * cos(tLat)
//        let x = cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(deltaLng)
//
//        let bearing = atan2(y, x)
//
//        return self.radiansToDegrees(x: bearing)
//    }
//
    func degreesToRadians(x: Double) -> Double {
        return .pi * x / 180.0
    }

    func radiansToDegrees(x: Double) -> Double {
        return x * 180.0 / .pi
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            //for getting just one route
            if let route = unwrappedResponse.routes.first {
                //show on map
                self.MvMapView.addOverlay(route.polyline)
            }
        }
    }
    
    func SetUpLocationMAnager(){
        locationManager = CLLocationManager()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        //        self.locationManager.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
    }
    
    func SetUI(){
        MvMapView.layer.cornerRadius = 10
        MvMapView.layer.borderWidth = 2
    }
    
}

