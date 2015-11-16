//
//  AppDelegate.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 8/17/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    lazy var coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        UINavigationBar.appearance().barTintColor = UIColor(red: (54/255), green: (54/255), blue: (54/255), alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: (125/255), green: (122/255), blue: (122/255), alpha: 1)]

        let containerViewController = ContainerViewController()
        if containerViewController.respondsToSelector("setCoreDataStack:"){
            containerViewController.performSelector("setCoreDataStack:", withObject: coreDataStack)
        }

        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()


        let defaults = NSUserDefaults.standardUserDefaults()
        let isPreloaded = defaults.boolForKey("isPreloadedCold")
        if !isPreloaded {
            preloadDataCold()
            defaults.setBool(true, forKey: "isPreloadedCold")
        }



        let isPreloadedHot = defaults.boolForKey("isPreloadedHot")
        if !isPreloadedHot {
            preloadDataHot()
            defaults.setBool(true, forKey: "isPreloadedHot")
        }


        
        return true
    }



    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
      NSNotificationCenter.defaultCenter().postNotificationName("updateWeather", object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
       coreDataStack.saveMainContext()
    }


    func parseCSV (contentsOfURL: NSURL, encoding: NSStringEncoding) throws -> [(type:String, quote:String)] {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // Load the CSV file and parse it
        let delimiter = ","
        var items:[(type:String, quote:String)]?

        do {
            let content = try String(contentsOfURL: contentsOfURL, encoding: encoding)
            items = []
            let lines:[String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]

            for line in lines {
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.rangeOfString("\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:NSScanner = NSScanner(string: textToScan)
                        while textScanner.string != "" {

                            if (textScanner.string as NSString).substringToIndex(1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpToString("\"", intoString: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpToString(delimiter, intoString: &value)
                            }

                            // Store the value into the values array
                            values.append(value as! String)

                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substringFromIndex(textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = NSScanner(string: textToScan)
                        }

                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values = line.componentsSeparatedByString(delimiter)
                    }

                    // Put the values into the tuple and add it to the items array
                    let item = (type: values[0], quote: values[1])
                    items?.append(item)
                }
            }
        } catch let error1 as NSError {
            error = error1
        }

        if let value = items {
            return value
        }
        throw error
    }



    func preloadDataCold () {
        // Retrieve data from the source file
        if let contentsOfURL = NSBundle.mainBundle().URLForResource("Cold", withExtension: "csv") {

            // Remove all the menu items before preloading
            removeDataCold()


            do {
                let items = try parseCSV(contentsOfURL, encoding: NSUTF8StringEncoding)
                // Preload the menu items

                    for item in items {
                        let coldQuotesItem = NSEntityDescription.insertNewObjectForEntityForName("ColdQuotes", inManagedObjectContext: coreDataStack.managedObjectContext) as! ColdQuotes

                        coldQuotesItem.type = item.type
                        coldQuotesItem.quote = item.quote

                        coreDataStack.saveMainContext()

                    }

            } catch let error1 as NSError {
                print("\(error1)")
            }
        }
    }

    func removeDataCold () {
        // Remove the existing items

            let fetchRequest = NSFetchRequest(entityName: "ColdQuotes")

            do{
                let questionItems = (try! coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as! [ColdQuotes]

                for question in questionItems {
                    coreDataStack.managedObjectContext.deleteObject(question)
                }
                
                try coreDataStack.managedObjectContext.save()
                
            }
            catch{
                print(error)
            }
            
            

    }


    func preloadDataHot () {
        // Retrieve data from the source file
        if let contentsOfURL = NSBundle.mainBundle().URLForResource("Hot", withExtension: "csv") {

            // Remove all the menu items before preloading
            removeDataHot()


            do {
                let items = try parseCSV(contentsOfURL, encoding: NSUTF8StringEncoding)
                // Preload the menu items

                    for item in items {
                        let hotQuotesItem = NSEntityDescription.insertNewObjectForEntityForName("HotQuotes", inManagedObjectContext: coreDataStack.managedObjectContext) as! HotQuotes

                        hotQuotesItem.type = item.type
                        hotQuotesItem.quote = item.quote

                         coreDataStack.saveMainContext()


                    }

            } catch let error1 as NSError {
                print("\(error1)")
            }
        }
    }

    func removeDataHot () {
        // Remove the existing items

            let fetchRequest = NSFetchRequest(entityName: "HotQuotes")

            do{
                let questionItems = (try! coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as! [HotQuotes]

                for question in questionItems {
                    coreDataStack.managedObjectContext.deleteObject(question)
                }

                coreDataStack.saveMainContext()
                
            }
//            catch{
//                print(error)
//            }

            

    }


}

