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
    
    
    //Will turn this into a dictinary to allow for multiple items later
    //for now I am just adding a car:)
    //var car = NSManagedObject()
    
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
        if(self.isCarAlreadySet(true)) {
            toggleButtonColor("Red")
        }
        
        //Not sure if this is right because the animation stops when I put it here versus after the button press
        self.locationManager.stopUpdatingLocation()
        
    }
    
    //Set a pin for new location or not
    //Eventually the pin will be cleared so I am just prepairing
    @IBAction func setCarLocation(){
        if(isCarAlreadySet(false)){
            println("Deleting car from core data")
            self.removeCarFromCoreData()
            self.myMap.removeAnnotations(myMap.annotations)
            self.toggleButtonColor("Blue")
        } else {
            self.setAnnotationForCar()
            self.persistObjectToCore()
            //self.locationManager.stopUpdatingLocation()
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
    func setAnnotationForCar(car: NSManagedObject){
        var lat: CLLocationDegrees = car.valueForKey("latitude")! as CLLocationDegrees
        var lon: CLLocationDegrees = car.valueForKey("longitude")! as CLLocationDegrees
        var anotation = MKPointAnnotation()
        var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        anotation.coordinate = location
        anotation.title = "Your Car is here"
        anotation.subtitle = "Go get it :)"
        myMap.addAnnotation(anotation)
    }
    
    //Set anotation for car if one does not exist
    func setAnnotationForCar(){
        var currentLocation: CLLocationCoordinate2D = self.locationManager.location.coordinate
        var anotation = MKPointAnnotation()
        var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        anotation.coordinate = location
        anotation.title = "Your Car is here"
        anotation.subtitle = "It has been saved :)"
        myMap.addAnnotation(anotation)
    }
    
    //Persist location data for object
    //I call this an object becasue in the future I am going allow the user to save multiple objects locations
    func persistObjectToCore(){
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.managedContext)
        
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext)
        
        var lat: Double = self.locationManager.location.coordinate.latitude
        var lon: Double = self.locationManager.location.coordinate.longitude
        
        item.setValue("Car", forKey: "object")
        item.setValue(lat, forKey: "latitude")
        item.setValue(lon, forKey: "longitude")
        
        var error: NSError?
        if(!self.managedContext.save(&error)){
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    //Check to see if a car is already set
    //In the future when the user can set more objects I will be adding more else if statements but for now it is just cars.
    func isCarAlreadySet(setAnotation: Bool) -> Bool{
        var arr = [AnyObject]()
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.managedContext)
        let fetchedRequest = NSFetchRequest(entityName: "ObjectLocation")
        var error: NSError?
        let fetchedResults = self.managedContext.executeFetchRequest(fetchedRequest, error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            for obj in results{
                var name: String = obj.valueForKey("object")! as NSString
                if(name == "Car"){
                    if(setAnotation){
                        self.setAnnotationForCar(obj)
                        self.locationManager.stopUpdatingLocation()
                    }
                    return true
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return false
    }
    
    //Here I am removing the car from core data
    func removeCarFromCoreData() {
        var arr = [AnyObject]()
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.managedContext)
        let fetchRequest = NSFetchRequest(entityName: "ObjectLocation")
        //let predicate = NSPredicate(format: "object == %s", "Car")
        //fetchRequest.predicate = predicate
        var error: NSError?
        let carObject = self.managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        if let results = carObject{
            for obj in results{
                var name: String = obj.valueForKey("object")! as NSString
                println(name)
                if(name == "Car"){
                    self.managedContext.deleteObject(obj)
                    var err: NSError?
                    if(!self.managedContext.save(&err)){
                        println("Could not save \(err), \(err?.userInfo)")
                    }
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
    }
    
    //Changing the add car button color
    func toggleButtonColor(s: String){
        if(s == "Red"){
            toggle.backgroundColor = UIColor.redColor()
            toggle.setTitle("-", forState: .Normal)
        } else {
            toggle.backgroundColor = UIColor.blueColor()
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


