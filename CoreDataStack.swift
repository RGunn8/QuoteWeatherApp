//
//  CoreDataStack.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 11/12/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack: NSObject {
    static let moduleName = "QuoteWeatherApp"

    func saveMainContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("Error saving main managed object context! \(error)")
            }
        }
    }

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        let persistentStoreURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(moduleName).sqlite")

        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: persistentStoreURL,
                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Persistent store error! \(error)")
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()

    func createCity(cityName: String, cityLat: Double,cityLong: Double, cityAtIndex: NSNumber, isCurrentLocation: Bool) {

        let entity = NSEntityDescription.entityForName("City", inManagedObjectContext: self.managedObjectContext)
        let city = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)

        city.setValue(cityName, forKey: "cityName")
        city.setValue(cityLat, forKey: "cityLat")
        city.setValue(cityLong, forKey: "cityLong")
        city.setValue(cityAtIndex, forKey: "cityAtIndex")
        city.setValue(isCurrentLocation, forKey: "isCurrentLocation")


        do {
            self.saveMainContext()
        }
    }
}
