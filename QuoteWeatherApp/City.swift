//
//  City.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 9/11/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import Foundation
import CoreData

class City: NSManagedObject {

    @NSManaged var cityAtIndex: NSNumber
    @NSManaged var cityLat: NSNumber
    @NSManaged var cityLong: NSNumber
    @NSManaged var cityName: String
    @NSManaged var isCurrentLocation: NSNumber

}
