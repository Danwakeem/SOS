//
//  TodayViewController.swift
//  SOSExtension
//
//  Created by Dan jarvis on 12/11/14.
//  Copyright (c) 2014 Dan jarvis. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
import CoreData

class TodayViewController: UIViewController, CLLocationManagerDelegate, NCWidgetProviding {
    
    var context: NSManagedObjectContext!
    var locationManager: CLLocationManager!
    var locationState: Bool = false
    
    @IBOutlet var saveLocation: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        self.context = self.managedObjectContext!
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.stopUpdatingLocation()
        
        if(isCarAlreadySet()){
            self.flipLocationState()
        }
        println(self.locationState)
    }
    
    @IBAction func saveThisLocation(){
        println("Getting location...")
        if(self.locationState){
            self.removeCarFromCoreData()
            self.flipLocationState()
        } else {
            self.addCarToCoreData()
            self.flipLocationState()
            //self.locationManager.stopUpdatingLocation()
        }
    }
    
    func isCarAlreadySet() -> Bool{
        var arr = [AnyObject]()
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.context)
        let fetchedRequest = NSFetchRequest(entityName: "ObjectLocation")
        var error: NSError?
        let fetchedResults = self.context.executeFetchRequest(fetchedRequest, error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            for obj in results{
                var name: String = obj.valueForKey("object")! as NSString
                if(name == "Car"){
                    return true
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return false
    }
    
    func addCarToCoreData(){
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.context)
        
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
        
        var lat: Double = self.locationManager.location.coordinate.latitude
        var lon: Double = self.locationManager.location.coordinate.longitude
        
        item.setValue("Car", forKey: "object")
        item.setValue(lat, forKey: "latitude")
        item.setValue(lon, forKey: "longitude")
        
        var error: NSError?
        if(!self.context.save(&error)){
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    //Here I am removing the car from core data
    func removeCarFromCoreData() {
        var arr = [AnyObject]()
        let entity = NSEntityDescription.entityForName("ObjectLocation", inManagedObjectContext: self.context)
        let fetchRequest = NSFetchRequest(entityName: "ObjectLocation")
        //let predicate = NSPredicate(format: "object == %s", "Car")
        //fetchRequest.predicate = predicate
        var error: NSError?
        let carObject = self.context.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        if let results = carObject{
            for obj in results{
                var name: String = obj.valueForKey("object")! as NSString
                if(name == "Car"){
                    self.context.deleteObject(obj)
                    var err: NSError?
                    if(!self.context.save(&err)){
                        println("Could not save \(err), \(err?.userInfo)")
                    }
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
    }
    
    func flipLocationState(){
        self.locationState = !self.locationState
        if(self.locationState){
            self.saveLocation.setTitle("Remove Car location", forState: .Normal)
        } else {
            self.saveLocation.setTitle("Save Location", forState: .Normal)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
