//
//  CityInfo.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 8/18/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class CityInfo: NSObject {
    static let sharedInstance = CityInfo()
    var name: String?
    var long: Double?
    var lat: Double?
    var cityID: String?
    var currentTemp: Double?
    var weeklyTempArray = [Int]()
    var weeklyDate = [String]()
   var coreDataStack = CoreDataStack()
    let apiKey = "b3d34aa21fbec905163da3d45d27db66"

    func searchCity(search: String, completionHandler:
        (Array<CityInfo>, NSError?) -> Void) {
        var cityResults = [CityInfo]()
            let urlEndPoint = "http://autocomplete.wunderground.com/aq"
            Alamofire.request(.GET, urlEndPoint, parameters: ["query": search]).responseJSON(completionHandler: {(response) -> Void in

                guard response.result.error == nil else {
                    print("Error has occur")
                    print(response.result.error)
                    return
                }
                if let data: AnyObject = response.result.value {
                let info = JSON(data)

                if let results = info["RESULTS"].array {
                    for city in results {
                        let theCity = CityInfo()
                        if let lat = city["lat"].string {
                            theCity.lat = (lat as NSString).doubleValue
                        }
                        if let lon = city["lon"].string {
                            theCity.long = (lon as NSString).doubleValue

                        }
                        if let name = city["name"].string {
                            theCity.name = name
                        }
                        cityResults.append(theCity)
                    }
                }
            }

            completionHandler(cityResults, response.result.error)
        })
    }

}

protocol CityInfoProtocol {
}

extension CityInfoProtocol {
    var apiKey: String{return "b3d34aa21fbec905163da3d45d27db66"}

    func getCityInfo(lat: Double, long: Double, completionHandler: (Result<OpenWeatherCity,NSError>) -> Void) {
        let theParameters: [String: String] = [
            "lat": "\(lat)",
            "lon": "\(long)",
            "APPID": apiKey
        ]
        let cityEndPoint = "http://api.openweathermap.org/data/2.5/weather"

        Alamofire.request(.GET, cityEndPoint, parameters: theParameters).responseObject({ (response: Response<OpenWeatherCity,NSError>) in
            completionHandler(response.result)

        })
    }

    func getFiveDay(lat: Double, long: Double , completionHandler: (Array<Int>?, Array<String>?,NSError?) -> Void) {

        let cityFiveEndPoint = "http://api.openweathermap.org/data/2.5/forecast/daily"
        var weeklyArray = [Int]()
        var weeklyDayArray = [String]()
         Alamofire.request(.GET, cityFiveEndPoint, parameters: ["lat": "\(lat)", "lon": "\(long)", "cnt": 6, "APPID": "b3d34aa21fbec905163da3d45d27db66"]).responseJSON {response in
            if let data: AnyObject = response.result.value {
                let json = JSON(data)

                weeklyArray.removeAll(keepCapacity: true)
                if let weekArray = json["list"].array {
                    for temp in weekArray {
                        if let theTemp = temp["temp"]["max"].int {
                            weeklyArray.append(theTemp)
                        }
                        if let theDate = temp["dt"].double {
                            let date = NSDate(timeIntervalSince1970: theDate)
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "EEE"
                            let stringDate = dateFormatter.stringFromDate(date)
                            weeklyDayArray.append(stringDate)
                        }
                    }
                }

            }
            completionHandler(weeklyArray, weeklyDayArray, response.result.error)
        }
    }

    func convertToCelsius(temp: Int) -> Int {
        let tempDouble = Double(temp)
        let celsius = tempDouble - 273.15
        let celsiusInt = Int(celsius)
        return celsiusInt

    }

    func convertToFahrenheit(temp: Int) -> Int {
        let tempDouble = Double(temp)
        let fahrenheit = tempDouble * (9/5) - 459.67
        let fahrenheitInt = Int(fahrenheit)
        return fahrenheitInt
    }

}
