//
//  YourCitiesTableViewController.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 8/20/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

@objc
protocol SidePanelViewControllerDelegate {
    func citySelected(city: City)

}

class YourCitiesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var coreDataStack: CoreDataStack!
    var numberOfCity = Int()
    var selectedCityIndex = 0
    var delegate: SidePanelViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchedResultController = getFetchedResultController()
        self.fetchedResultController.delegate = self
        let error = NSErrorPointer()
        do {
            try fetchedResultController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
        }
        navigationItem.leftBarButtonItem = editButtonItem()


    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchedResultController = getFetchedResultController()

        let error = NSErrorPointer()
        do {
            try fetchedResultController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
        }
        self.tableView.reloadData()

    }

    func getFetchedResultController() -> NSFetchedResultsController {
    fetchedResultController = NSFetchedResultsController(fetchRequest: fetchCity(), managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResultController
    }

    func fetchCity() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "City")
        fetchRequest.returnsObjectsAsFaults = false

        let sortDescriptor = NSSortDescriptor(key: "cityAtIndex", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        return fetchRequest
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }

    override func  setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)

    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        numberOfCity = numberOfRowsInSection!
        return numberOfRowsInSection!
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCellID", forIndexPath: indexPath) as! CityCell // tailor:disable

        if let city = fetchedResultController.objectAtIndexPath(indexPath) as? City {
            cell.configureForCity(city)
        }

        // Configure the cell...

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let city = fetchedResultController.objectAtIndexPath(indexPath) as? City {
            delegate?.citySelected(city)
        }

    }


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {


        if let cityToBeDelete = fetchedResultController.objectAtIndexPath(indexPath) as? City {
              coreDataStack.managedObjectContext.deleteObject(cityToBeDelete)
              coreDataStack.saveMainContext()
        }

    }

}
