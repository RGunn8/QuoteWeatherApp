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
    var name:String?
    var long:Double?
    var lat:Double?
    var cityID:String?
    var currentTemp:Double?
    var weeklyTempArray = [Int]()
    var weeklyDate = [String]()
   var coreDataStack = CoreDataStack()
    var alamofireManager:Alamofire.Manager
    let apiKey = "b3d34aa21fbec905163da3d45d27db66"

    override init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        alamofireManager = Alamofire.Manager(configuration: configuration)
        super.init()

    }



//    func getCityInfo(lat:Double, long:Double, completion: (CityInfo?) -> ()) -> () {
//
//        let theCity = CityInfo()
//        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: ["lat": "\(lat)", "lon":"\(long)","APPID":"b3d34aa21fbec905163da3d45d27db66"]).responseJSON {
//
//            (Response) in
//            if let data: AnyObject = Response.data{
//                let info = JSON(data)
//            
//                if let thename = info["name"].string{
//                    theCity.name = thename
//
//                }
//                if let coord = info["coord"].dictionaryObject{
//                    theCity.lat = coord["lat"] as? Double
//                    theCity.long = coord["lon"] as? Double
//
//                }
//                if let id = info["id"].double{
//                    theCity.cityID = "\(id)"
//                }
//                if let currentTemp = info["main"]["temp"].double{
//                        theCity.currentTemp = currentTemp
//                }
//
//            }
//            completion(theCity)
//
//        }
//
//    }

    func getCityInfo(lat:Double, long:Double, completionHandler: (Result<OpenWeatherCity,NSError>) ->Void){

        let theParameters:[String:String] = [
            "lat": "\(lat)",
            "lon": "\(long)",
            "APPID":apiKey
        ]
        let cityEndPoint = "http://api.openweathermap.org/data/2.5/weather"

        alamofireManager.request(.GET, cityEndPoint, parameters:theParameters).responseObject({ (response:Response<OpenWeatherCity,NSError>) in

            completionHandler(response.result)

        })
        
    }


    func getFiveDay(lat:Double, long:Double , completionHandler: (Array<Int>?, Array<String>?) ->Void) {

        let cityFiveEndPoint = "http://api.openweathermap.org/data/2.5/forecast/daily"
        var weeklyArray = [Int]()
        var weeklyDayArray = [String]()
        Alamofire.request(.GET, cityFiveEndPoint, parameters:["lat": "\(lat)", "lon":"\(long)", "cnt":6, "APPID":"b3d34aa21fbec905163da3d45d27db66"]).responseJSON {Response in
            if let data:AnyObject = Response.result.value{
                let json = JSON(data)

                weeklyArray.removeAll(keepCapacity: true)
                if let weekArray = json["list"].array{
                    for temp in weekArray{
                        if let theTemp = temp["temp"]["max"].int{
                            weeklyArray.append(theTemp)
                        }
                        if let theDate = temp["dt"].double{
                            let date = NSDate(timeIntervalSince1970: theDate)
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "EEE"
                            let stringDate = dateFormatter.stringFromDate(date)
                            weeklyDayArray.append(stringDate)
                        }
                    }
                }

            }
            completionHandler(weeklyArray, weeklyDayArray)
        }
    }


    func searchCity(search:String, completionHandler:
        (Array<CityInfo>) -> Void) {
        var cityResults = [CityInfo]()
            let urlEndPoint = "http://autocomplete.wunderground.com/aq"
            Alamofire.request(.GET, urlEndPoint, parameters:["query":search]).responseJSON(completionHandler: { (Response) -> Void in

                guard Response.result.error == nil else {
                    print("Error has occur")
                    print(Response.result.error)
                    return
                }
                if let data:AnyObject = Response.result.value{
                let info = JSON(data)
                if let results = info["RESULTS"].array{
                    for city in results{

                        let theCity = CityInfo()


                        if let lat = city["lat"].string{
                            theCity.lat = (lat as NSString).doubleValue
                        }
                        if let lon = city["lon"].string{
                            theCity.long = (lon as NSString).doubleValue

                        }
                        if let name = city["name"].string{
                            theCity.name = name
                        }


                        
                        cityResults.append(theCity)
                    }
                }
            }

            completionHandler(cityResults)

        
        })
    }

//
//    func theCity(lat:Double, long:Double){
//        getCityInfo(lat, long: long, completion: { (city,error) in
//            if let city  = city{
//                //println("\(city.name)  \(city.cityID) \(city.lat), \(city.long) ")
//            }else{
//                print("somehting happen that wasn't suppose to")
//            }
//
//        })
//    }

    func createCity(cityName:String, cityLat:Double,cityLong:Double, cityAtIndex:NSNumber, isCurrentLocation:Bool) {

        let entity = NSEntityDescription.entityForName("City", inManagedObjectContext:coreDataStack.managedObjectContext)
        let city = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)

        city.setValue(cityName, forKey: "cityName")
        city.setValue(cityLat, forKey: "cityLat")
        city.setValue(cityLong, forKey: "cityLong")
        city.setValue(cityAtIndex, forKey: "cityAtIndex")
        city.setValue(isCurrentLocation, forKey: "isCurrentLocation")


        do {
           coreDataStack.saveMainContext()
        }

//        print("\(city)")

    }

    func returnCity(cityName:String, cityLat:Double,cityLong:Double, cityAtIndex:NSNumber, isCurrentLocation:Bool) -> City {

        let entity = NSEntityDescription.entityForName("City", inManagedObjectContext:coreDataStack.managedObjectContext)
        let city = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)

        city.setValue(cityName, forKey: "cityName")
        city.setValue(cityLat, forKey: "cityLat")
        city.setValue(cityLong, forKey: "cityLong")
        city.setValue(cityAtIndex, forKey: "cityAtIndex")
        city.setValue(isCurrentLocation, forKey: "isCurrentLocation")


        do {
            coreDataStack.saveMainContext()
        } 
        print("\(city)")

        return city as! City
        
    }



   
}
