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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var numberOfCity = Int()
    var selectedCityIndex = 0
    var delegate: SidePanelViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchedResultController = getFetchedResultController()
        self.fetchedResultController.delegate = self
        let error = NSErrorPointer()
        fetchedResultController.performFetch(error)
        navigationItem.leftBarButtonItem = editButtonItem()


    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchedResultController = getFetchedResultController()

        let error = NSErrorPointer()
        fetchedResultController.performFetch(error)
        self.tableView.reloadData()

    }

    func getFetchedResultController() -> NSFetchedResultsController {
    fetchedResultController = NSFetchedResultsController(fetchRequest: fetchCity(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResultController
    }

    func fetchCity() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "City")
        fetchRequest.returnsObjectsAsFaults = false

        let sortDescriptor = NSSortDescriptor(key: "cityAtIndex", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        return fetchRequest
    }
    func save() {
        var error:NSError?
        if managedObjectContext!.save(&error){
            println(error?.localizedDescription)
        }

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
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCellID", forIndexPath: indexPath) as! CityCell

         var theCity = fetchedResultController.objectAtIndexPath(indexPath) as! City
        cell.configureForCity(theCity)
        // Configure the cell...

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
     {
        var theCity = fetchedResultController.objectAtIndexPath(indexPath) as! City
        delegate?.citySelected(theCity)

    }


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {


            // Find the LogItem object the user is trying to delete
            let deleteCity:City = fetchedResultController.objectAtIndexPath(indexPath) as! City


            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(deleteCity)
             managedObjectContext?.save(nil)
            //tableView.reloadData()
          }


}


class CityCell: UITableViewCell {
    @IBOutlet var cityName: UILabel!

    func configureForCity(city:City){
        cityName.text = city.cityName

    }


}
