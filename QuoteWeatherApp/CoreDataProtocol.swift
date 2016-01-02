//
//  CoreDataProtocol.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 1/1/16.
//  Copyright © 2016 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataError: ErrorType {
    case CouldNotRetriveData
}
protocol CoreDataProtocol {

}

extension CoreDataProtocol {

    func fetchCities(coreDataStack: CoreDataStack) throws -> Array<City> {
        let fetchRequest = NSFetchRequest(entityName: "City")
        let sortDescriptor = NSSortDescriptor(key: "isCurrentLocation", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]


        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [City] {
            return fetchResults
        }else {
            throw CoreDataError.CouldNotRetriveData
        }



    }

    func fetchHotQuote(coreDataStack: CoreDataStack) throws -> Array<HotQuotes> {
        let fetchRequest = NSFetchRequest(entityName: "HotQuotes")

            if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [HotQuotes] {
            return fetchResults

            }else {
                throw CoreDataError.CouldNotRetriveData
        }


    }

    func fetchColdQuote(coreDataStack: CoreDataStack) throws -> Array<ColdQuotes> {
        let fetchRequest = NSFetchRequest(entityName: "ColdQuotes")


            if let coldQuotes = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [ColdQuotes] {
               return coldQuotes

            }else {
                throw CoreDataError.CouldNotRetriveData
        }

    }

}
