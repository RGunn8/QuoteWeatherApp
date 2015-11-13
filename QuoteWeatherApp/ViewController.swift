//
//  ViewController.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 8/17/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

@objc
protocol CenterViewControllerDelegate {

    optional func toggleRightPanel()
    optional func collapseSidePanels()
}


class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var theDegreeLabel: DegreeLabel!

    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    var fahrenheitTemp = [Int]()
    var celsiusTemp = [Int]()
    var currentCelsius = Int()
    var currentFahrenheit = Int()

    var cityInfo = CityInfo()
    var lat = Double()
    var long = Double()
    var cityName = String()
    var pageIndex = Int()
    var isCurrentLocation = true
    var isFahrenheitTemp = true
     var delegate: CenterViewControllerDelegate?
    var CBarButtonItem:UIBarButtonItem = UIBarButtonItem()
    var FBarButtonItem:UIBarButtonItem = UIBarButtonItem()
    var cities = [City]()
       let defaults = NSUserDefaults.standardUserDefaults()
    var coreDataStack:CoreDataStack!
    

    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var dayOneDegreeLabel: UILabel!

    @IBOutlet weak var dayFiveLabel: UILabel!
    @IBOutlet weak var dayFiveDegreeLabel: UILabel!
    @IBOutlet weak var dayFourLabel: UILabel!
    @IBOutlet weak var dayFourDegreeLabel: UILabel!
    @IBOutlet weak var dayThreeLabel: UILabel!
    @IBOutlet weak var dayThreeDegreeLabel: UILabel!
    @IBOutlet weak var dayTwoLabel: UILabel!
    @IBOutlet weak var dayTwoDegreeLabel: UILabel!
    @IBOutlet weak var dayOneLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        CBarButtonItem = UIBarButtonItem(title: "C", style: UIBarButtonItemStyle.Plain, target: self, action: "CTapped:")
        // 2
        FBarButtonItem = UIBarButtonItem(title: "F", style: UIBarButtonItemStyle.Plain, target: self, action: "FTapped:")


        fetchCities()

          self.locationManager.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLocation", name: "updateWeather", object: nil)



    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isCurrentLocation{
        setName(lat, long: long)


        setWeather(lat, long: long)
        }
       //println("\(isFahrenheitTemp)")

        //updateLocation()


           }

    func setDegreeLable() {

        let isCelsius = defaults.boolForKey("isCelsius")

        if isCelsius{
            self.theDegreeLabel.curValue = CGFloat(self.currentCelsius)

        }else{
            self.theDegreeLabel.curValue = CGFloat(self.currentFahrenheit)
        }

        if self.currentCelsius < 0 || self.currentFahrenheit < 0 {
            self.theDegreeLabel.curValue = 0
        }

    }
    func setWeatherLabels() {

        let isCelsius = defaults.boolForKey("isCelsius")

        if isCelsius {
            self.theDegreeLabel.curValue = CGFloat(self.currentCelsius)
            self.dayOneDegreeLabel.text = "\(self.celsiusTemp[1])"
            self.dayTwoDegreeLabel.text = "\(self.celsiusTemp[2])"
            self.dayThreeDegreeLabel.text = "\(self.celsiusTemp[3])"
            self.dayFourDegreeLabel.text = "\(self.celsiusTemp[4])"
            self.dayFiveDegreeLabel.text = "\(self.celsiusTemp[5])"

        }else{
            self.theDegreeLabel.curValue = CGFloat(self.currentFahrenheit)
            self.dayOneDegreeLabel.text = "\(self.fahrenheitTemp[1])"
            self.dayTwoDegreeLabel.text = "\(self.fahrenheitTemp[2])"
            self.dayThreeDegreeLabel.text = "\(self.fahrenheitTemp[3])"
            self.dayFourDegreeLabel.text = "\(self.fahrenheitTemp[4])"
            self.dayFiveDegreeLabel.text = "\(self.fahrenheitTemp[5])"
        }

    }

    func FTapped(sender:UIButton) {
        //println("F pressed")
        self.navigationItem.leftBarButtonItem = CBarButtonItem
        //self.viewControllerFarenheitTemp(true, index: 0)
        self.theDegreeLabel.curValue = CGFloat(self.currentFahrenheit)
        self.dayOneDegreeLabel.text = "\(self.fahrenheitTemp[1])"
        self.dayTwoDegreeLabel.text = "\(self.fahrenheitTemp[2])"
        self.dayThreeDegreeLabel.text = "\(self.fahrenheitTemp[3])"
        self.dayFourDegreeLabel.text = "\(self.fahrenheitTemp[4])"
        self.dayFiveDegreeLabel.text = "\(self.fahrenheitTemp[5])"

        let defaults = NSUserDefaults.standardUserDefaults()
//        let isCelsius = defaults.boolForKey("isCelsius")

            defaults.setBool(false, forKey: "isCelsius")


    }

    func CTapped(sender:UIButton) {
        //println("c pressed")
        self.theDegreeLabel.curValue = CGFloat(self.currentCelsius)
        self.dayOneDegreeLabel.text = "\(self.celsiusTemp[1])"
        self.dayTwoDegreeLabel.text = "\(self.celsiusTemp[2])"
        self.dayThreeDegreeLabel.text = "\(self.celsiusTemp[3])"
        self.dayFourDegreeLabel.text = "\(self.celsiusTemp[4])"
        self.dayFiveDegreeLabel.text = "\(self.celsiusTemp[5])"

        self.navigationItem.leftBarButtonItem = FBarButtonItem
        //self.viewControllerFarenheitTemp(false, index: 0)

        let defaults = NSUserDefaults.standardUserDefaults()
        //        let isCelsius = defaults.boolForKey("isCelsius")

        defaults.setBool(true, forKey: "isCelsius")

    }


    func ChangeToFahrenheit(notification: NSNotification){
        print("F tapped")

    }

      func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }

    func setTemp(isFarh:Bool){
        isFahrenheitTemp = isFarh
    }

    func setName(lat:Double, long:Double) {
        CityInfo.sharedInstance.getCityInfo(lat, long: long, completionHandler:  {(result) -> Void in

            guard result.error == nil else {
                print("Error has occur")
                return
            }
            guard let city = result.value else {
                print("Error on result callded")
                return
            }

            let fah = city.currentTemp! * (9/5) - 459.67
            self.currentFahrenheit = Int(fah)
            let cels = city.currentTemp! - 273.15
            self.currentCelsius = Int(cels)


            dispatch_async(dispatch_get_main_queue()){

                self.setDegreeLable()
                self.theDegreeLabel.range = CGFloat(100)
              //self.cityLabel.text = self.cityName

                if self.isCurrentLocation {
                    self.cityLabel.text = city.name
                }else{
                    self.cityLabel.text = self.cityName
                }

                if self.currentFahrenheit >= 68 {
                self.fetchHotQuote()
                }else{
                    self.fetchColdQuote()
                }



                
            }
            
            
        })
    

    }

 


    func setWeather(lat:Double, long:Double){
   
        cityInfo.getFiveDay(lat, long: long) { (temp, dates ) -> () in

                if let temp = temp{
                   self.fahrenheitTemp.removeAll(keepCapacity: true)
                    self.celsiusTemp.removeAll(keepCapacity: true)
                    for fah in temp{

                        let fahDouble = Double(fah)
                        let theFah = fahDouble * (9/5) - 459.67
                        let fahInt = Int(theFah)
                        self.fahrenheitTemp.append(fahInt)
                    }

                    for cel in temp {
                        let celDouble = Double(cel)
                        let theCel = celDouble - 273.15
                        let celInt = Int(theCel)
                        self.celsiusTemp.append(celInt)
                    }

                    self.setWeatherLabels()

                }

                if let dates = dates {
                      dispatch_async(dispatch_get_main_queue()){
                    self.dayOneLabel.text = dates[1]
                    self.dayTwoLabel.text = dates[2]
                    self.dayThreeLabel.text = dates[3]
                    self.dayFourLabel.text = dates[4]
                        self.dayFiveLabel.text = dates[5]


                        let isCelsius = self.defaults.boolForKey("isCelsius")
                        if isCelsius{
                            self.navigationItem.leftBarButtonItem = self.FBarButtonItem

                        }else{
                            self.navigationItem.leftBarButtonItem = self.CBarButtonItem
                        }
                    }

                }
            }

    }

    @IBAction func CitiyTapped(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }

       func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {

            updateLocation()
//            let city:CityWeather = CityWeather()
//            city.getCurrentTemp(locValue.latitude, long: locValue.longitude, indicator:self.indicator)

        }else{
            manager.requestWhenInUseAuthorization()
        }
    }
    func fetchCities(){
        let fetchRequest = NSFetchRequest(entityName: "City")
        let sortDescriptor = NSSortDescriptor(key: "isCurrentLocation", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [City] {
            cities = fetchResults

        }

//        do {
//            theCities = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [City]
//            if let cityArray = theCities {
//                cities = cityArray
//            }
//        }catch {
//            theCities = nil
//
//
//        }

//        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [City] {
//            cities = fetchResults
//
//        }
    }

    func fetchHotQuote() {
        let fetchRequest = NSFetchRequest(entityName: "HotQuotes")

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [HotQuotes] {
           let hotQuotes = fetchResults
            let randomIndex = Int(arc4random_uniform(UInt32(hotQuotes.count)))

            let theHotQuote = hotQuotes[randomIndex]
            quoteLabel.text = theHotQuote.quote

        }
    }

    func fetchColdQuote() {
        let fetchRequest = NSFetchRequest(entityName: "ColdQuotes")

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [ColdQuotes] {
            let coldQuotes = fetchResults
            let randomIndex = Int(arc4random_uniform(UInt32(coldQuotes.count)))

            let theColdQuote = coldQuotes[randomIndex]
            quoteLabel.text = theColdQuote.quote
            
        }
    }


    func updateLocation() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {

            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //self.locationManager.distanceFilter = 10

            self.locationManager.startUpdatingLocation()

        } else {
            locationManager.requestWhenInUseAuthorization()

        }
        
        
    }


    @IBAction func plusButtonPressed(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("plusButtonPressed", object: nil)
    }


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        locationManager.stopUpdatingLocation()
        print("locations = \(locValue.latitude) \(locValue.longitude)")


        CityInfo.sharedInstance.getCityInfo(locValue.latitude, long: locValue.longitude) { (theCity) -> () in

            guard let city = theCity.value else {
                print("Error on result callded")
                print(theCity.error)
                return
            }


            if self.cities.count == 0 {
                 //var ThecurrentLocation = City()
                let cityInfo = CityInfo()
                cityInfo.createCity(city.name!, cityLat: locValue.latitude, cityLong: locValue.longitude, cityAtIndex: 0, isCurrentLocation: true)
                self.setName(locValue.latitude, long: locValue.longitude)

                self.setWeather(locValue.latitude, long: locValue.longitude)

            }else{
                 let ThecurrentLocation:City = self.cities[0]
                ThecurrentLocation.setValue(locValue.latitude, forKey: "cityLat")
                ThecurrentLocation.setValue(locValue.longitude, forKey: "cityLong")
                ThecurrentLocation.setValue(city.name, forKey: "cityName")
                ThecurrentLocation.setValue(true, forKey: "isCurrentLocation")
                print(ThecurrentLocation.cityName)
                do {
                    self.coreDataStack.saveMainContext()
                }
            }


            }

        if self.isCurrentLocation{
            self.setName(locValue.latitude, long: locValue.longitude)

            self.setWeather(locValue.latitude, long: locValue.longitude)
        }

        }



    }


extension ViewController: SidePanelViewControllerDelegate {
    func citySelected(city: City) {

//        println("city = \(city.cityLong), \(city.cityLat)")
        cityName = city.cityName
        lat = Double(city.cityLat)
        long = Double(city.cityLong)
        if city.isCurrentLocation == 0 {
            isCurrentLocation = false
        }else{
            isCurrentLocation = true
        }

        print("\(isCurrentLocation)")
        setWeather(lat, long: long)
        setName(lat, long: long)

        delegate?.collapseSidePanels?()
    }



}

extension ViewController: SearchViewControllerDelegate  {
    func cityPicked(lat: Double, long: Double, name: String) {
        self.lat = lat
        self.long = long
        self.cityName = name
        isCurrentLocation = false

        setWeather(lat, long: long)
        setName(lat, long: long)
        print("delgate called")

        //delegate?.collapseSidePanels?()
}
}



