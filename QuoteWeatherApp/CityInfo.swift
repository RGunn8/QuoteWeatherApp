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
    var name:String?
    var long:Double?
    var lat:Double?
    var cityID:String?
    var currentTemp:Double?
    var weeklyTempArray = [Int]()
    var weeklyDate = [String]()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext



    func getCityInfo(lat:Double, long:Double, completion: (CityInfo?,NSError?) -> ()) -> () {

        var theCity = CityInfo()
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: ["lat": "\(lat)", "lon":"\(long)","APPID":"b3d34aa21fbec905163da3d45d27db66"]).responseJSON {

            (request,response,data,error) in
            if let data: AnyObject = data{
                let info = JSON(data)
            
                if let thename = info["name"].string{
                    theCity.name = thename

                }
                if let coord = info["coord"].dictionaryObject{
                    theCity.lat = coord["lat"] as? Double
                    theCity.long = coord["lon"] as? Double

                }
                if let id = info["id"].double{
                    theCity.cityID = "\(id)"
                }
                if let currentTemp = info["main"]["temp"].double{
                        theCity.currentTemp = currentTemp
                }

            }
            completion(theCity, error)

        }

    }

    func getFiveDay(lat:Double, long:Double, completion: (Array<Int>?,Array<String>?,NSError?) -> ()) -> () {


        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: ["lat": "\(lat)", "lon":"\(long)", "cnt":6, "APPID":"b3d34aa21fbec905163da3d45d27db66"]).responseJSON {

            (request,response,data,error) in
            if let data: AnyObject = data{
                let info = JSON(data)
                self.weeklyTempArray.removeAll(keepCapacity: true)
                if let weeklyArray = info["list"].array{
                    for temp in weeklyArray{
                        if let theTemp = temp["temp"]["max"].int{

                            self.weeklyTempArray.append(theTemp)
                            //println("\(theTemp)")
                        }
                        if let theDate = temp["dt"].double{
                            let date = NSDate(timeIntervalSince1970: theDate)
                            let dataformater = NSDateFormatter()
                            dataformater.dateFormat = "EEE"
                            let stringDate = dataformater.stringFromDate(date)
                            self.weeklyDate.append(stringDate)
                            //println("\(stringDate)")
                        }
                    }
                }


            }

            completion(self.weeklyTempArray,self.weeklyDate, error)
            //            
        }
    }

    func searchCity(search:String, completion:(Array<CityInfo>?, NSError?) -> ()) -> () {
        var cityResults = [CityInfo]()
        Alamofire.request(.GET, "http://autocomplete.wunderground.com/aq",parameters: ["query": "\(search)"]).responseJSON{
            (request,response,data,error) in
            if let data:AnyObject = data{
                let info = JSON(data)
                if let results = info["RESULTS"].array{
                    for city in results{

                        var theCity = CityInfo()


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

                       completion(cityResults,error)
           
        
        }
    }

    func theCity(lat:Double, long:Double){
        getCityInfo(lat, long: long, completion: { (city,error) in
            if let city  = city{
                //println("\(city.name)  \(city.cityID) \(city.lat), \(city.long) ")
            }else{
                println("somehting happen that wasn't suppose to")
            }

        })
    }

    func createCity(cityName:String, cityLat:Double,cityLong:Double, cityAtIndex:NSNumber, isCurrentLocation:Bool) {

        let entity = NSEntityDescription.entityForName("City", inManagedObjectContext:managedObjectContext!)
        let city = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)

        city.setValue(cityName, forKey: "cityName")
        city.setValue(cityLat, forKey: "cityLat")
        city.setValue(cityLong, forKey: "cityLong")
        city.setValue(cityAtIndex, forKey: "cityAtIndex")
        city.setValue(isCurrentLocation, forKey: "isCurrentLocation")

        var error:NSError?
        managedObjectContext?.save(nil)

        println("\(city)")
        
    }

    func returnCity(cityName:String, cityLat:Double,cityLong:Double, cityAtIndex:NSNumber, isCurrentLocation:Bool) -> City {

        let entity = NSEntityDescription.entityForName("City", inManagedObjectContext:managedObjectContext!)
        let city = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)

        city.setValue(cityName, forKey: "cityName")
        city.setValue(cityLat, forKey: "cityLat")
        city.setValue(cityLong, forKey: "cityLong")
        city.setValue(cityAtIndex, forKey: "cityAtIndex")
        city.setValue(isCurrentLocation, forKey: "isCurrentLocation")

        var error:NSError?
        managedObjectContext?.save(nil)

        println("\(city)")

        return city as! City
        
    }



   
}
