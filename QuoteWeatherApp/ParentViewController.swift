//
//  ParentViewController.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 8/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ParentViewController: UIViewController, UIPageViewControllerDataSource, CLLocationManagerDelegate {
    var pageViewController: UIPageViewController!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var cities = [City]()
    var didSegue = false
    var segueIndex = 1
    var CBarButtonItem:UIBarButtonItem = UIBarButtonItem()
    var FBarButtonItem:UIBarButtonItem = UIBarButtonItem()
   

    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
       CBarButtonItem = UIBarButtonItem(title: "C", style: UIBarButtonItemStyle.Plain, target: self, action: "CTapped:")
        // 2
         FBarButtonItem = UIBarButtonItem(title: "F", style: UIBarButtonItemStyle.Plain, target: self, action: "FTapped:")
         3
        self.navigationItem.setRightBarButtonItems([FBarButtonItem,CBarButtonItem], animated: true)



        fetchCities()

        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.dataSource = self

         //let ThecurrentLocation:City = self.cities[0]
//        var theFirstVC = firstVC(ThecurrentLocation.cityLat, long: ThecurrentLocation.cityLong, name: ThecurrentLocation.cityName)
//        var viewControllersArray = [theFirstVC]
//        pageViewController.setViewControllers(viewControllersArray, direction: .Forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRectMake(0, 0, view.frame.width, view.frame.size.height)

        addChildViewController(pageViewController)
        pageViewController.didMoveToParentViewController(self)
        view.addSubview(pageViewController.view)
    }

   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateLocation()
        println("\(didSegue), and the selected city is \(segueIndex)")
        if didSegue {
            let segueCity:City = self.cities[segueIndex]
            var segueVC = self.firstVC(segueCity.cityLat, long: segueCity.cityLong, name: segueCity.cityName)
            var viewControllersArray = [segueCity]
            pageViewController.setViewControllers(viewControllersArray, direction: .Forward, animated: true, completion: nil)
        }
    }

    func FTapped(sender:UIButton) {
        //println("F pressed")
         self.navigationItem.rightBarButtonItem = CBarButtonItem
        //self.viewControllerFarenheitTemp(true, index: 0)
        NSNotificationCenter.defaultCenter().postNotificationName("FTapped", object: nil)
    }

    func CTapped(sender:UIButton) {
        //println("c pressed")
        NSNotificationCenter.defaultCenter().postNotificationName("CTapped", object: nil)

        self.navigationItem.rightBarButtonItem = FBarButtonItem
        //self.viewControllerFarenheitTemp(false, index: 0)
        
    }

    func viewControllerFarenheitTemp(isFarenheit:Bool, index:Int) -> ViewController {
//        if cities.count == 0 || index >= cities.count {
//            return ViewController()
//        }
//
       var vc:ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ViewController
//        var cityAtIndex:City = cities[index]
//        vc.lat = cityAtIndex.cityLat as Double
//        vc.long = cityAtIndex.cityLong as Double
//        vc.cityName = cityAtIndex.cityName
//        vc.pageIndex = index
//        vc.isFahrenheitTemp = isFarenheit
//        if index == 0{
//            vc.isCurrentLocation = true
//            //println(vc.lat)
//        }else{
//            vc.isCurrentLocation = false
//        }
//        //println(vc.isFahrenheitTemp)
        return vc


    }

    func viewControllerAtIndex(index:Int) -> ViewController{
        if cities.count == 0 || index >= cities.count {
            return ViewController()
        }

        var vc:ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ViewController
        var cityAtIndex:City = cities[index]
        vc.lat = cityAtIndex.cityLat as Double
        vc.long = cityAtIndex.cityLong as Double
        vc.cityName = cityAtIndex.cityName
        vc.pageIndex = index

        if index == 0{
            vc.isCurrentLocation = true
            println(vc.lat)
        }else{
            vc.isCurrentLocation = false
        }


        return vc

    }

    func firstVC(lat:NSNumber,long:NSNumber, name:String) -> ViewController{
         var vc:ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ViewController
       let latDouble = Double(lat)
        let longDouble = Double(long)
        vc.lat = latDouble
        vc.long = longDouble
        vc.cityName = name
        return vc
    }

    func fetchCities(){
        let fetchRequest = NSFetchRequest(entityName: "City")
        let sortDescriptor = NSSortDescriptor(key: "cityAtIndex", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
               if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [City] {
            cities = fetchResults

             
                
                   }

    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! ViewController
        var index = vc.pageIndex as Int

        if index == 0 || index == NSNotFound {
            return nil
        }
        index--
        return viewControllerAtIndex(index)
    }


    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! ViewController
        var index = vc.pageIndex as Int
        if index == NSNotFound {
            return nil
        }

        index++
        if index == cities.count {
            return nil
        }

        return viewControllerAtIndex(index)

    }



    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return cities.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
       return 0
    }

    func updateLocation() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //self.locationManager.distanceFilter = 10

            self.locationManager.startUpdatingLocation()

        } else {
            locationManager.requestWhenInUseAuthorization()

        }
        
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        //fetchStudio(manager.location, radiusInMeters: 10000)
        locationManager.stopUpdatingLocation()
        println("locations = \(locValue.latitude) \(locValue.longitude)")
        let currentLocationCityInfo = CityInfo()
        currentLocationCityInfo.getCityInfo(locValue.latitude, long: locValue.longitude) { (theCity, error) -> () in
            let ThecurrentLocation:City = self.cities[0]
            ThecurrentLocation.setValue(locValue.latitude, forKey: "cityLat")
            ThecurrentLocation.setValue(locValue.longitude, forKey: "cityLong")
            ThecurrentLocation.setValue(theCity?.name, forKey: "cityName")
            println(ThecurrentLocation.cityName)
             self.managedObjectContext?.save(nil)
            var theFirstVC = self.firstVC(ThecurrentLocation.cityLat, long: ThecurrentLocation.cityLong, name: ThecurrentLocation.cityName)
            var viewControllersArray = [theFirstVC]
       self.pageViewController.setViewControllers(viewControllersArray, direction: .Forward, animated: true, completion: nil)
        }






    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            if cities.count == 0{
                let city = CityInfo()
                city.createCity("Current Location", cityLat: 41.5102, cityLong: -87.7406, cityAtIndex: 0)
               fetchCities()
            }



//            self.locationManager.startUpdatingLocation()
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        }else{

        }
    }





}
