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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    override func viewDidLoad() {
        super.viewDidLoad()
        CBarButtonItem = UIBarButtonItem(title: "C", style: UIBarButtonItemStyle.Plain, target: self, action: "CTapped:")
        // 2
        FBarButtonItem = UIBarButtonItem(title: "F", style: UIBarButtonItemStyle.Plain, target: self, action: "FTapped:")
        3
        self.navigationItem.leftBarButtonItem = CBarButtonItem
        fetchCities()
        updateLocation()


    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isCurrentLocation{
        setName(lat, long: long)


        setWeather(lat, long: long)
        }
       //println("\(isFahrenheitTemp)")

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

    }


    func ChangeToFahrenheit(notification: NSNotification){
        println("F tapped")


    }

      func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location Manager failed with the following error: \(error)")
    }

    func setTemp(isFarh:Bool){
        isFahrenheitTemp = isFarh
    }
 
    func setName(lat:Double, long:Double){
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        cityInfo.getCityInfo(lat, long: long) { (theCity, error) -> () in
            if error != nil{
                println("\(error)")
            }else{
                self.indicator.stopAnimating()
                if let city = theCity{

                    if self.isCurrentLocation {
                        self.cityLabel.text = city.name
                    }else{
                        self.cityLabel.text = self.cityName
                    }

                    var fah = city.currentTemp! * (9/5) - 459.67
                    self.currentFahrenheit = Int(fah)
                    var cels = city.currentTemp! - 273.15
                    self.currentCelsius = Int(cels)
//                    self.degreeLabel.text = "\(self.currentFahrenheit)"
                    self.theDegreeLabel.curValue = CGFloat(self.currentFahrenheit)
                    self.theDegreeLabel.range = CGFloat(100)

                }
            }
        }
    }

    func setWeather(lat:Double, long:Double){
   
        cityInfo.getFiveDay(lat, long: long) { (temp, dates, error) -> () in
            if error != nil{
                println("\(error)")
            }else {
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

                    self.dayOneDegreeLabel.text = "\(self.fahrenheitTemp[1])"
                    self.dayTwoDegreeLabel.text = "\(self.fahrenheitTemp[2])"
                    self.dayThreeDegreeLabel.text = "\(self.fahrenheitTemp[3])"
                    self.dayFourDegreeLabel.text = "\(self.fahrenheitTemp[4])"
                    self.dayFiveDegreeLabel.text = "\(self.fahrenheitTemp[5])"

                }

                if let dates = dates {
                    self.dayOneLabel.text = dates[1]
                    self.dayTwoLabel.text = dates[2]
                    self.dayThreeLabel.text = dates[3]
                    self.dayFourLabel.text = dates[4]
                    self.dayFiveLabel.text = dates[5]

                }
            }
        }
    }

    @IBAction func CitiyTapped(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }

       func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {


//            let city:CityWeather = CityWeather()
//            city.getCurrentTemp(locValue.latitude, long: locValue.longitude, indicator:self.indicator)

        }
    }
    func fetchCities(){
        let fetchRequest = NSFetchRequest(entityName: "City")
        let sortDescriptor = NSSortDescriptor(key: "isCurrentLocation", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [City] {
            cities = fetchResults

        }
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


    @IBAction func plusButtonPressed(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("plusButtonPressed", object: nil)
    }


    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate

        locationManager.stopUpdatingLocation()
        println("locations = \(locValue.latitude) \(locValue.longitude)")

        let currentLocationCityInfo = CityInfo()
        currentLocationCityInfo.getCityInfo(locValue.latitude, long: locValue.longitude) { (theCity, error) -> () in

            if self.cities.count == 0 {
                 //var ThecurrentLocation = City()
                var cityInfo = CityInfo()
                cityInfo.createCity("Current Location", cityLat: locValue.latitude, cityLong: locValue.longitude, cityAtIndex: 0, isCurrentLocation: true)
//                ThecurrentLocation.setValue(locValue.latitude, forKey: "cityLat")
//                ThecurrentLocation.setValue(locValue.longitude, forKey: "cityLong")
//                ThecurrentLocation.setValue(theCity?.name, forKey: "cityName")
//                ThecurrentLocation.setValue(true, forKey: "isCurrentLocation")
//                println(ThecurrentLocation.cityName)
//                self.managedObjectContext?.save(nil)
            }else{
                 var ThecurrentLocation:City = self.cities[0]
                ThecurrentLocation.setValue(locValue.latitude, forKey: "cityLat")
                ThecurrentLocation.setValue(locValue.longitude, forKey: "cityLong")
                ThecurrentLocation.setValue(theCity?.name, forKey: "cityName")
                ThecurrentLocation.setValue(true, forKey: "isCurrentLocation")
                println(ThecurrentLocation.cityName)
                self.managedObjectContext?.save(nil)
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

        println("\(isCurrentLocation)")
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
        println("delgate called")

        //delegate?.collapseSidePanels?()
}
}



