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

@IBDesignable
class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var theDegreeLabel: DegreeLabel!

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    var fahrenheitTemp = [Int]()
    var celsiusTemp = [Int]()
    var currentCelsius = Int()
    var currentFahrenheit = Int()
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    var cityInfo = CityInfo()
    var lat = Double()
    var long = Double()
    var cityName = String()
    var pageIndex = Int()
    var isCurrentLocation = false
    var isFahrenheitTemp = true
    

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ChangeToFahrenheit:", name:"FTapped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ChangeToCelsius:", name:"CTapped", object: nil)


    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isCurrentLocation{
        setName(lat, long: long)

        setWeather(lat, long: long)
        }
       println("\(isFahrenheitTemp)")

        //setupLocationManager()
       //checkLocationAuthorizationStatus()
       

    }

    func ChangeToFahrenheit(notification: NSNotification){
        println("F tapped")
         self.theDegreeLabel.curValue = CGFloat(self.currentFahrenheit)
        self.dayOneDegreeLabel.text = "\(self.fahrenheitTemp[1])"
        self.dayTwoDegreeLabel.text = "\(self.fahrenheitTemp[2])"
        self.dayThreeDegreeLabel.text = "\(self.fahrenheitTemp[3])"
        self.dayFourDegreeLabel.text = "\(self.fahrenheitTemp[4])"
        self.dayFiveDegreeLabel.text = "\(self.fahrenheitTemp[5])"
    }

    func ChangeToCelsius(notification: NSNotification){
        println("C tapped")
         self.theDegreeLabel.curValue = CGFloat(self.currentCelsius)
        self.dayOneDegreeLabel.text = "\(self.celsiusTemp[1])"
        self.dayTwoDegreeLabel.text = "\(self.celsiusTemp[2])"
        self.dayThreeDegreeLabel.text = "\(self.celsiusTemp[3])"
        self.dayFourDegreeLabel.text = "\(self.celsiusTemp[4])"
        self.dayFiveDegreeLabel.text = "\(self.celsiusTemp[5])"
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


       func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {


//            let city:CityWeather = CityWeather()
//            city.getCurrentTemp(locValue.latitude, long: locValue.longitude, indicator:self.indicator)

        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        //fetchStudio(manager.location, radiusInMeters: 10000)
        locationManager.stopUpdatingLocation()
        println("locations = \(locValue.latitude) \(locValue.longitude)")
        if isCurrentLocation{
        setName(locValue.latitude, long: locValue.longitude)

        setWeather(locValue.latitude, long: locValue.longitude)
    }
    }



}

