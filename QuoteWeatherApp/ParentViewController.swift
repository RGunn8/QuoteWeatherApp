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



class ParentViewController: UIViewController, CLLocationManagerDelegate {
   
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var cities = [City]()
    var didSegue = false
    var segueIndex = 1
   
   
   

    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
       

        fetchCities()

    }



    func viewControllerFarenheitTemp(isFarenheit:Bool, index:Int) -> ViewController {
//        if cities.count == 0 || index >= cities.count {
//            return ViewController()
//        }
//
       let vc:ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ViewController
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

        let vc:ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ViewController
        let cityAtIndex:City = cities[index]
        vc.lat = cityAtIndex.cityLat as Double
        vc.long = cityAtIndex.cityLong as Double
        vc.cityName = cityAtIndex.cityName
        vc.pageIndex = index

        if index == 0{
            vc.isCurrentLocation = true
            print(vc.lat)
        }else{
            vc.isCurrentLocation = false
        }


        return vc

    }

    func firstVC(lat:NSNumber,long:NSNumber, name:String) -> ViewController{
         let vc:ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ViewController
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
               if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [City] {
            cities = fetchResults

             
                
                   }

    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ViewController
        var index = vc.pageIndex as Int

        if index == 0 || index == NSNotFound {
            return nil
        }
        index--
        return viewControllerAtIndex(index)
    }


    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ViewController
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //fetchStudio(manager.location, radiusInMeters: 10000)
        locationManager.stopUpdatingLocation()
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let currentLocationCityInfo = CityInfo()
        currentLocationCityInfo.getCityInfo(locValue.latitude, long: locValue.longitude) { (theCity) -> () in
            let ThecurrentLocation:City = self.cities[0]
            ThecurrentLocation.setValue(locValue.latitude, forKey: "cityLat")
            ThecurrentLocation.setValue(locValue.longitude, forKey: "cityLong")
            ThecurrentLocation.setValue(theCity.value!.name, forKey: "cityName")
            ThecurrentLocation.setValue(true, forKey: "isCurrentLocation")
            print(ThecurrentLocation.cityName)
            do {
                try self.managedObjectContext?.save()
            } catch _ {
            }

//       self.pageViewController.setViewControllers(viewControllersArray, direction: .Forward, animated: true, completion: nil)
        }
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            if cities.count == 0{
                let city = CityInfo()
                city.createCity("Current Location", cityLat: 41.5102, cityLong: -87.7406, cityAtIndex: 0, isCurrentLocation:true)
               fetchCities()
            }



//            self.locationManager.startUpdatingLocation()
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        }else{

        }
    }


//    private extension UIStoryboard {
//        class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
//
//        class func leftViewController() -> SidePanelViewController? {
//            return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
//        }
//
//        class func rightViewController() -> SidePanelViewController? {
//            return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? SidePanelViewController
//        }
//
//        class func centerViewController() -> CenterViewController? {
//            return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
//        }
//    }




}
