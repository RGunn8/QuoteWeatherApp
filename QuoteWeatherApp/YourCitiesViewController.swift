//
//  YourCitiesViewController.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 11/1/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

class YourCitiesViewController: UIViewController, UINavigationBarDelegate,UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navBar: UINavigationBar!
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var coreDataStack = CoreDataStack()
    var numberOfCity = Int()
    var selectedCityIndex = 0
    var delegate: SidePanelViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        let navItem = navigationItem
        let editButton = editButtonItem();
        navItem.rightBarButtonItem = editButton



        fetchedResultController.delegate = self
        let barButtonArray = [navItem]
       navBar.items = barButtonArray


        fetchedResultController = getFetchedResultController()

        let error = NSErrorPointer()
        do {
            try fetchedResultController.performFetch()
        } catch let error1 as NSError {
            error.memory = error1
        }


        self.navBar.delegate = self; 

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
                
        self.tableView.reloadData()
       

    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {


        if type == NSFetchedResultsChangeType.Delete{
            print("Delete")
        }
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
//    func save() {
//        var error:NSError?
//        do {
//            try managedObjectContext!.save()
//            print(error?.localizedDescription)
//        } catch let error1 as NSError {
//            error = error1
//            print(error)
//        }
//
//    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }

    override func  setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)

    }
    // MARK: - Table view data source

     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return false

            }
        }

        return true
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        numberOfCity = numberOfRowsInSection!
        return numberOfRowsInSection!
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCellID", forIndexPath: indexPath) as! CityCell

        let theCity = fetchedResultController.objectAtIndexPath(indexPath) as! City
        cell.configureForCity(theCity)

        print(theCity.cityName)
        // Configure the cell...

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let theCity = fetchedResultController.objectAtIndexPath(indexPath) as! City
        delegate?.citySelected(theCity)

    }


     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {


        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let deleteAlarms:City = fetchedResultController.objectAtIndexPath(indexPath) as! City


            // Delete it from the managedObjectContext
            coreDataStack.managedObjectContext.deleteObject(deleteAlarms)


            // Refresh the table view to indicate that it's deleted
            //tableView.reloadData()

            


            do {
               coreDataStack.saveMainContext()
            }
            //println("\(deleteAlarms.on)")
           

            let error = NSErrorPointer()
            do {
                try fetchedResultController.performFetch()
            } catch let error1 as NSError {
                error.memory = error1
            }


            tableView.reloadData()

            
        }

    }

    


}

class CityCell: UITableViewCell {


    @IBOutlet var cityLabel: UILabel!
    func configureForCity(city:City){
        cityLabel.text = city.cityName
        //print(city.cityName)
    }


}

extension YourCitiesViewController : UIBarPositioningDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
