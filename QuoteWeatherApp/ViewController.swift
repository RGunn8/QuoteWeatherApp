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
import Alamofire

@objc
protocol CenterViewControllerDelegate {

    optional func toggleRightPanel()
    optional func collapseSidePanels()
}


class ViewController: UIViewController, CLLocationManagerDelegate, CityInfoProtocol {
    @IBOutlet weak var theDegreeLabel: DegreeLabel!
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    var fahrenheitTemp = [Int]()
    var celsiusTemp = [Int]()
    var currentCelsius = Int()
    var currentFahrenheit = Int()
    var lat = Double()
    var long = Double()
    var cityName = String()
    var pageIndex = Int()
    var isCurrentLocation = true
    var isFahrenheitTemp = true
     var delegate: CenterViewControllerDelegate?
    var cBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    var fBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    var cities = [City]()
    var hotQuotes = [HotQuotes]()
    var coldQuotes = [ColdQuotes]()
    var coreDataStack: CoreDataStack!
    var aboutToUpdateFromAppDelegate = false


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

        quoteLabel.adjustsFontSizeToFitWidth = true
        fetchCities()
        navigationController?.navigationItem.titleView?.backgroundColor = UIColor.redColor()

          self.locationManager.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateWeatherFromTheAppDelegate", name: "updateWeather", object: nil)
      setBarButtons()

    }

       override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !isCurrentLocation {
        setName(lat, long: long)

        setWeather(lat, long: long)
        }

    }

    func setBarButtons() {

        cBarButtonItem = UIBarButtonItem(title: "C", style: UIBarButtonItemStyle.Plain, target: self, action: "CTapped")
        // 2
        fBarButtonItem = UIBarButtonItem(title: "F", style: UIBarButtonItemStyle.Plain, target: self, action: "FTapped")
        cBarButtonItem.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor(red: (245/255), green: (245/255), blue: (245/255), alpha: 1)],
            forState: UIControlState.Normal)

        fBarButtonItem.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor(red: (245/255), green: (245/255), blue: (245/255), alpha: 1)],
            forState: UIControlState.Normal)

    }

    func fTapped() {
        navigationItem.leftBarButtonItem = cBarButtonItem
        theDegreeLabel.curValue = CGFloat(currentFahrenheit)
        dayOneDegreeLabel.text = "\(fahrenheitTemp[1])°"
        dayTwoDegreeLabel.text = "\(fahrenheitTemp[2])°"
        dayThreeDegreeLabel.text = "\(fahrenheitTemp[3])°"
        dayFourDegreeLabel.text = "\(fahrenheitTemp[4])°"
        dayFiveDegreeLabel.text = "\(fahrenheitTemp[5])°"
        setIsCelsius(false)

    }

    func cTapped() {
        self.theDegreeLabel.curValue = CGFloat(self.currentCelsius)
        self.dayOneDegreeLabel.text = "\(self.celsiusTemp[1])°"
        self.dayTwoDegreeLabel.text = "\(self.celsiusTemp[2])°"
        self.dayThreeDegreeLabel.text = "\(self.celsiusTemp[3])°"
        self.dayFourDegreeLabel.text = "\(self.celsiusTemp[4])°"
        self.dayFiveDegreeLabel.text = "\(self.celsiusTemp[5])°"
        self.navigationItem.leftBarButtonItem = fBarButtonItem
        setIsCelsius(true)
        
    }

    func setIsCelsius(isCelsius:Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(isCelsius, forKey: "isCelsius")
    }

    func isCelsius() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey("isCelsius")
    }


    func setDegreeLable() {

        if isCelsius() {
            self.theDegreeLabel.curValue = CGFloat(self.currentCelsius)
            if self.currentCelsius < 0 {
                self.theDegreeLabel.curValue = 0
            }

        }else {
            self.theDegreeLabel.curValue = CGFloat(self.currentFahrenheit)

            if self.currentFahrenheit < 0 {
                self.theDegreeLabel.curValue = 0
            }
        }

    }

    func setWeatherLabels() {

        if isCelsius() {
          cTapped()

        }else {
            fTapped()
        }

    }

    func setWeather(lat: Double, long: Double) {

        getFiveDay(lat, long: long) { (temp, dates, error ) -> () in

            if error != nil {
                if let error = error {
                    self.presentErrorAlerViewController(error.description)
                }
                return
            }

            if let temp = temp {
                self.fahrenheitTemp.removeAll(keepCapacity: true)
                self.celsiusTemp.removeAll(keepCapacity: true)
                for fah in temp {
                    self.fahrenheitTemp.append(self.convertToFahrenheit(fah))
                }

                for cel in temp {
                    self.celsiusTemp.append(self.convertToCelsius(cel))
                }

                self.setWeatherLabels()

            }

            if let dates = dates {
                dispatch_async(dispatch_get_main_queue()) {
                   self.setDateLabels(dates)

                    if self.isCelsius() {
                        self.navigationItem.leftBarButtonItem = self.fBarButtonItem

                    }else {
                        self.navigationItem.leftBarButtonItem = self.cBarButtonItem
                    }
                }
                
            }
        }
        
    }

    func setDateLabels(dateArray:Array<String>) {
        dayOneLabel.text = dateArray[1]
        dayTwoLabel.text = dateArray[2]
        dayThreeLabel.text = dateArray[3]
        dayFourLabel.text = dateArray[4]
        dayFiveLabel.text = dateArray[5]
    }


    func setName(lat: Double, long: Double) {

       indicator.startAnimating()
      getCityInfo(lat, long: long, completionHandler: {(result) -> Void in

            guard result.error == nil else {
                if let error = result.error {
                      self.presentErrorAlerViewController(error.description)
                }
                self.indicator.stopAnimating()
                return
            }
            guard let currentCity = result.value else {
              self.presentErrorAlerViewController("Cannot fetch City")
                return
            }

            self.indicator.stopAnimating()
        if let currentTemp = currentCity.currentTemp {
            let currentTempInt = Int(currentTemp)
            self.currentCelsius = self.convertToCelsius(currentTempInt)
            self.currentFahrenheit = self.convertToFahrenheit(currentTempInt)
        }

            dispatch_async(dispatch_get_main_queue()) {

                self.updateNameAndQuote(currentCity)
            }
        })

    }

    func updateNameAndQuote(currentCity: OpenWeatherCity) {
        self.setDegreeLable()
        self.theDegreeLabel.range = CGFloat(100)

        if self.isCurrentLocation {
            self.cityLabel.text = currentCity.name
        } else {
            self.cityLabel.text = self.cityName
        }

        if self.currentFahrenheit >= 68 {
            self.fetchHotQuote()
        } else {
            self.fetchColdQuote()
        }

    }


    @IBAction func citiesTapped(sender: UIBarButtonItem) {
        delegate?.toggleRightPanel?()
    }


    func fetchCities() {
        let fetchRequest = NSFetchRequest(entityName: "City")
        let sortDescriptor = NSSortDescriptor(key: "isCurrentLocation", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [City] {
            cities = fetchResults

        }


    }

    func fetchHotQuote() {
        let fetchRequest = NSFetchRequest(entityName: "HotQuotes")

        if hotQuotes.isEmpty {
        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [HotQuotes] {
           hotQuotes = fetchResults
            let randomIndex = Int(arc4random_uniform(UInt32(hotQuotes.count)))

            let theHotQuote = hotQuotes[randomIndex]
            quoteLabel.text = theHotQuote.quote

            }
        }else {
            let randomIndex = Int(arc4random_uniform(UInt32(hotQuotes.count)))

            let theHotQuote = hotQuotes[randomIndex]
            quoteLabel.text = theHotQuote.quote

        }
    }

    func fetchColdQuote() {
        let fetchRequest = NSFetchRequest(entityName: "ColdQuotes")

        if coldQuotes.isEmpty {
        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [ColdQuotes] {
             coldQuotes = fetchResults
            let randomIndex = Int(arc4random_uniform(UInt32(coldQuotes.count)))

            let theColdQuote = coldQuotes[randomIndex]
            print(theColdQuote.quote)
            quoteLabel.text = theColdQuote.quote

            }
        }else {
                let randomIndex = Int(arc4random_uniform(UInt32(coldQuotes.count)))
                let theColdQuote = coldQuotes[randomIndex]
                print(theColdQuote.quote)
                quoteLabel.text = theColdQuote.quote

        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {

            updateLocation()

        }else {
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
        indicator.stopAnimating()
        return

    }

    func updateLocation() {

        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()

        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate

        locationManager.stopUpdatingLocation()

        getCityInfo(locValue.latitude, long: locValue.longitude) { (theCity) -> () in

            guard let city = theCity.value else {
                print("Error on result callded")
                print(theCity.error)
                return
            }


            if self.cities.count == 0 {
                self.coreDataStack.createCity(city.name!, cityLat: locValue.latitude, cityLong: locValue.longitude, cityAtIndex: 0, isCurrentLocation: true)
                self.setName(locValue.latitude, long: locValue.longitude)

                self.setWeather(locValue.latitude, long: locValue.longitude)

            }else {
                let currentLocation: City = self.cities[0]
                currentLocation.setValue(locValue.latitude, forKey: "cityLat")
                currentLocation.setValue(locValue.longitude, forKey: "cityLong")
                currentLocation.setValue(city.name, forKey: "cityName")
                currentLocation.setValue(true, forKey: "isCurrentLocation")
                do {
                    self.coreDataStack.saveMainContext()
                }
            }

        }

            if self.isCurrentLocation {
            self.setName(locValue.latitude, long: locValue.longitude)
            
            self.setWeather(locValue.latitude, long: locValue.longitude)
            }
        
    }

    @IBAction func plusButtonPressed(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("plusButtonPressed", object: nil)
    }

    func presentErrorAlerViewController(errorString: String) {

        let alertController = UIAlertController(title: "Error", message: "An Error has Occured,\(errorString)", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        let oKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(oKAction)

        self.presentViewController(self, animated: true, completion: nil)
        
    }


    func updateWeatherFromTheAppDelegate() {
        aboutToUpdateFromAppDelegate = true
        if aboutToUpdateFromAppDelegate {
            // update app when it become active from background
            updateLocation()
        }else {
            // update app the regular way, make sure updateLocation doesn't get called twice
            updateLocation()
        }

    }


    }


extension ViewController: SidePanelViewControllerDelegate {

    func citySelected(city: City) {
        cityName = city.cityName
        lat = Double(city.cityLat)
        long = Double(city.cityLong)
        if city.isCurrentLocation == 0 {
            isCurrentLocation = false
        }else {
            isCurrentLocation = true
        }

        setWeather(lat, long: long)
        setName(lat, long: long)

        delegate?.collapseSidePanels?()
    }

}

extension ViewController: SearchViewControllerDelegate {

    func cityPicked(lat: Double, long: Double, name: String) {
        self.lat = lat
        self.long = long
        self.cityName = name
        isCurrentLocation = false

        setWeather(lat, long: long)
        setName(lat, long: long)

    }

}
