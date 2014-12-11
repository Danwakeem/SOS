//
//  SOSCoreDataModel.swift
//  SOS
//
//  Created by Dan jarvis on 12/11/14.
//  Copyright (c) 2014 Dan jarvis. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

//Need to make this class a frame work so I can access it from my today extension
public class SOSKitModel{
    
    //Will add a dictionary of objects later but for now it is just the CoreData access methods
    //let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    public var managedContext: NSManagedObjectContext!
    
    public init(){
        managedContext = self.managedObjectContext!
    }
    
    //Persist location data for object
    //I call this an object becasue in the future I am going allow the user to save multiple objects locations
    public func persistObjectToCore(locationManager: CLLocationManager){
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
    public func isCarAlreadySet() -> NSManagedObject!{
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
    public func removeCarFromCoreData() {
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
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Danwakeem.SOS" in the application's documents Application Support directory.
        
        //let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        //return urls[urls.count-1] as NSURL
        
        //I replaced the two lines above to allow the main app to write to the app group core data that way I can share the data with the
        //today extension
        let urls = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.SOS")
        return urls!
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SOS.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}

