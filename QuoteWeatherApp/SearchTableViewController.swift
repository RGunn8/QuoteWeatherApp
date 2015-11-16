//
//  SearchTableViewController.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 8/20/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
@objc
protocol SearchViewControllerDelegate {
    func cityPicked(lat:Double, long:Double, name:String)
}

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {

    var filteredTableData = [CityInfo]()
    var resultSearchController:UISearchController!
    var searchResultsCity = [CityInfo]()
    let city = CityInfo()
    var numOfCity = Int()
    var coreDataStack = CoreDataStack()
    var delegate: SearchViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        resultSearchController = UISearchController(searchResultsController: nil)
        // 2
        resultSearchController.searchResultsUpdater = self
        // 3
        resultSearchController.hidesNavigationBarDuringPresentation = false
        // 4
        resultSearchController.dimsBackgroundDuringPresentation = false
        // 5
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
        // 6
        resultSearchController.searchBar.sizeToFit()
        // 7
        self.tableView.tableHeaderView = resultSearchController.searchBar
        definesPresentationContext = true

          self.tableView.reloadData()
    }

 



    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       let searchNumbers = NSCharacterSet(charactersInString: "0123456789")
        if (self.resultSearchController.active) {

            if self.resultSearchController.searchBar.text == "" || self.resultSearchController.searchBar.text == " "{
                return 0
            } else if ((self.resultSearchController.searchBar.text?.rangeOfCharacterFromSet(searchNumbers)) != nil) {
              
                return 0

            }else{

            return self.filteredTableData.count
            }
        }
        else {
            return 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCellID", forIndexPath: indexPath) 

        // 3
        if (self.resultSearchController.active) {


            let cityAtIndex:CityInfo = self.filteredTableData[indexPath.row]


            cell.textLabel?.text = cityAtIndex.name

            return cell
        }
        else {
            cell.textLabel?.text = ""

            return cell
        }    }


    func updateSearchResultsForSearchController(searchController: UISearchController)
    {

        city.searchCity(searchController.searchBar.text!, completionHandler: { (city) -> () in

                self.filteredTableData = city.0

            //println("\(self.filteredTableData)")
            self.tableView.reloadData()
        })


        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (searchResultsCity as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [CityInfo]


    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = self.filteredTableData[indexPath.row]

        var theCityName = String()
        var theCityLat = Double()
        var theCityLong = Double()
    

        if let cityName = selectedItem.name{
             cityName
            var myArray = cityName.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: ",-"))
          
            let theCity = myArray[0]
           theCityName  = theCity
        }

        if let citylat = selectedItem.lat{
            theCityLat = citylat
        }

        if let cityLong = selectedItem.long{
            theCityLong = cityLong
        }
       let newCityNumber = numOfCity + 1

       coreDataStack.createCity(theCityName, cityLat: theCityLat, cityLong: theCityLong, cityAtIndex: newCityNumber, isCurrentLocation: false)


        delegate?.cityPicked(theCityLat, long: theCityLong, name: theCityName)

       self.navigationController!.popViewControllerAnimated(true)
    }



}
