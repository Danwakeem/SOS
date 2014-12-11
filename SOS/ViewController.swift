//
//  ViewController.swift
//  StuffFinder
//
//  Created by Dan jarvis on 12/7/14.
//  Copyright (c) 2014 Dan jarvis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var myMap: MKMapView!
    
    @IBOutlet var toggle: UIButton!
    
    var locationManager: CLLocationManager!
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedContext: NSManagedObjectContext!
    let CoreModel = CoreDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting up managedContext so I can use core Data later
        self.managedContext = appDelegate.managedObjectContext!
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //Load from Core Data if avalible
        if let obj = self.CoreModel.isCarAlreadySet(self.managedContext) {
            self.setAnnotationForCar(car: obj)
            toggleButtonColor("Red")
        } else {
            if(myMap.annotations != nil){
                myMap.removeAnnotations(myMap.annotations)
                toggleButtonColor("Blue")
            }
        }
        
    }
    
    //Set a pin for new location or remove existing pin
    @IBAction func setCarLocation(){
        if let obj = self.CoreModel.isCarAlreadySet(self.managedContext){
            println("Deleting car from core data")
            self.CoreModel.removeCarFromCoreData(self.managedContext)
            self.myMap.removeAnnotations(myMap.annotations)
            self.toggleButtonColor("Blue")
        } else {
            self.setAnnotationForCar()
            self.CoreModel.persistObjectToCore(self.locationManager ,managedContext: self.managedContext)
            self.locationManager.stopUpdatingLocation()
            toggleButtonColor("Red")
        }
    }
    
    //Just a dumb log for debugging
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        NSLog("Added annnotation ")
    }
    
    //Set the region for the map when I start updating location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let center = CLLocationCoordinate2D(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.myMap.setRegion(region, animated: true)
    }
    
    //Set anotation for car after getting location from CoreData
    func setAnnotationForCar(car: NSManagedObject! = nil){
        if(car != nil){
            var lat: CLLocationDegrees = car.valueForKey("latitude")! as CLLocationDegrees
            var lon: CLLocationDegrees = car.valueForKey("longitude")! as CLLocationDegrees
            var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            var anotation = MKPointAnnotation()
            anotation.coordinate = location
            anotation.title = "Your Car is here"
            anotation.subtitle = "Go get it :)"
            myMap.addAnnotation(anotation)
        } else {
            var currentLocation: CLLocationCoordinate2D = self.locationManager.location.coordinate
            var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            var anotation = MKPointAnnotation()
            anotation.coordinate = location
            anotation.title = "Your Car is here"
            anotation.subtitle = "It has been saved :)"
            myMap.addAnnotation(anotation)
        }
    }
    
    //Changing the add car button color
    func toggleButtonColor(s: String){
        if(s == "Red"){
            toggle.backgroundColor = UIColor(red: 220.0 / 255.0, green: 68.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
            toggle.setTitle("-", forState: .Normal)
        } else {
            toggle.backgroundColor = UIColor(red: 62.0 / 255.0, green: 121.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
            //toggle.backgroundColor = UIColor.blueColor()
            toggle.setTitle("+", forState: .Normal)
        }
    }
    
    //Rid the screen of the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


