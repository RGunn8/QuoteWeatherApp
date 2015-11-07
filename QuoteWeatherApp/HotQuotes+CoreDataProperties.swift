//
//  HotQuotes+CoreDataProperties.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 11/1/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HotQuotes {

    @NSManaged var type: String?
    @NSManaged var quote: String?

}
