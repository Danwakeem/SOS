//
//  CoreDataModel.swift
//  SOS
//
//  Created by Dan jarvis on 12/11/14.
//  Copyright (c) 2014 Dan jarvis. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

//Need to make this class a frame work so I can access it from my today extension
class CoreDataModel{
    
    //Will add a dictionary of objects later but for now it is just the CoreData access methods
    //let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let appDelegate = AppDelegate()
    var managedContext: NSManagedObjectContext!
    
    init(){
        managedContext = self.appDelegate.managedObjectContext!
    }
    
    //Persist location data for object
    //I call this an object becasue in the future I am going allow the user to save multiple objects locations
    func persistObjectToCore(locationManager: CLLocationManager){
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.managedContext)
        
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext)
        
        var lat: Double = locationManager.location.coordinate.latitude
        var lon: Double = locationManager.location.coordinate.longitude
        
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
    func isCarAlreadySet() -> NSManagedObject!{
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.managedContext)
        let fetchedRequest = NSFetchRequest(entityName: "ObjectLocation")
        var error: NSError?
        let fetchedResults = self.managedContext.executeFetchRequest(fetchedRequest, error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            for obj in results{
                var name: String = obj.valueForKey("object")! as NSString
                if(name == "Car"){
                    return obj
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return nil
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
    
}
