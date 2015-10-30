//
//  OpenWeatherCity.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 10/29/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

public protocol ResponseJSONObjectSerializable {
    init?(json: SwiftyJSON.JSON)
}

class OpenWeatherCity: NSObject, ResponseJSONObjectSerializable {
    var weeklyTempArray = [Int]()
    var weeklyDate = [String]()
    var name:String?
    var long:Double?
    var lat:Double?
    var currentTemp:Double?
    var weather:String?

    required init? (json:JSON){
        self.name = json["name"].string
        self.currentTemp = json["main"]["temp"].double
        self.lat = json["coord"]["lat"].double
        self.long = json["coord"]["lon"].double

        for result in json["weather"].arrayValue{
            self.weather = result["main"].string
        }
        //        self.weather = json["weather"]["description"].string
    }



}

extension Alamofire.Request {
    public func responseObject<T: ResponseJSONObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)

            if result.isSuccess {
                if let value = result.value {
                    let json = SwiftyJSON.JSON(value)
                    if let newObject = T(json: json) {
                        return .Success(newObject)
                    }
                }
            }
            let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: "JSON could not be converted to object")
            return .Failure(error)
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    public func responseArray<T: ResponseJSONObjectSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)

            switch result {
            case .Success(let value):
                let json = SwiftyJSON.JSON(value)
                var objects: [T] = []
                for (_, item) in json {
                    if let object = T(json: item) {
                        objects.append(object)
                    }
                }
                return .Success(objects)
            case .Failure(let error):
                return .Failure(error)
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
}