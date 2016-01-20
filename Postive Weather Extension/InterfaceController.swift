//
//  InterfaceController.swift
//  Postive Weather Extension
//
//  Created by Ryan  Gunn on 11/22/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

struct CityWeather {
    let weather:String
    let temp:Double
    let name:String
}

class InterfaceController: WKInterfaceController,CLLocationManagerDelegate  {

    @IBOutlet var weatherLabel: WKInterfaceLabel!
    @IBOutlet var tempLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    var locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        self.locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }


   

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]

        let lat:Double = currentLocation.coordinate.latitude
        let long:Double = currentLocation.coordinate.longitude

        updateVC(lat, long: long)

    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error.description)")
    }

    func updateVC(lat:Double, long:Double) {

        loadCityInfo(lat, long: long) { (city, error) -> Void in
            if error != nil {

                print("Error has occur")
                self.tempLabel.setText("Error Has Occured")
            }

            var theName:String
            var theTemp:Double
            var theWeather:String

            theTemp = city.temp

             let fah = theTemp * (9/5) - 459.67
            let fahInt = Int(fah)
            theWeather = city.weather
            theName = city.name

              dispatch_async(dispatch_get_main_queue()){
                self.nameLabel.setText(theName)
                self.tempLabel.setText("\(fahInt)")
                self.weatherLabel.setText(theWeather)

            }
        }
        
    }




        func loadCityInfo (lat:Double, long:Double, completionHandler:(CityWeather,NSError?) ->Void) {
            let apiKey:String = "b3d34aa21fbec905163da3d45d27db66"
            let cityEndPoint = "http://api.openweathermap.org/data/2.5/weather"
            let theParameters:[String:String] = [
                "lat": "\(lat)",
                "lon": "\(long)",
                "APPID":apiKey
            ]
            let parameterString = theParameters.stringFromHttpParameters()

            guard let url = NSURL(string: "\(cityEndPoint)?\(parameterString)") else {
                print("Error: cannot create URL")
                return
            }

            var cityName = String()
            var cityWeather = String()
            var cityTemp = Double()
            let urlRequest = NSURLRequest(URL: url)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)

            let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
                guard let responseData = data else {
                    print("Error: did not receive data")
                    return
                }
                guard error == nil else {
                    print("error calling GET on /posts/1")
                    print(error)
                    return
                }
                // parse the result as JSON, since that's what the API provides
                let post: NSDictionary
                do {
                    post = try NSJSONSerialization.JSONObjectWithData(responseData,
                        options: []) as! NSDictionary
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
                
                if let name = post["name"] as? String{
                    cityName = name
                }
                
                if let temp = post["main"]!["temp"] as? Double {
                    cityTemp = temp
                }

//                for result in json["weather"].arrayValue{
//                    self.weather = result["main"].string
//                }

                if let weather = post["weather"] as? NSArray{
                    for result in weather {
                        cityWeather = result["main"] as! String
                    }
                }

                
                let cityWeather = CityWeather(weather: cityWeather, temp: cityTemp, name: cityName)

                completionHandler(cityWeather,error)
            }
            task.resume()
        }


}
