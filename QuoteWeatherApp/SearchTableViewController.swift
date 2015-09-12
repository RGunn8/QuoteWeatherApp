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
    var resultSearchController = UISearchController()
    var searchResultsCity = [CityInfo]()
    let city = CityInfo()
    var numOfCity = Int()
    var delegate: SearchViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(numOfCity)")
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
           controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()

            self.tableView.tableHeaderView = controller.searchBar

            return controller
        })()
        definesPresentationContext = true

          self.tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            if self.resultSearchController.searchBar.text == "" || self.resultSearchController.searchBar.text == " "{
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCellID", forIndexPath: indexPath) as! UITableViewCell

        // 3
        if (self.resultSearchController.active) {


            var cityAtIndex:CityInfo = self.filteredTableData[indexPath.row]


            cell.textLabel?.text = cityAtIndex.name

            return cell
        }
        else {
            cell.textLabel?.text = ""

            return cell
        }    }


    func updateSearchResultsForSearchController(searchController: UISearchController)
    {

        city.searchCity(searchController.searchBar.text, completion: { (city, error) -> () in
            if let cityArray = city{
                self.filteredTableData = cityArray
            }
            //println("\(self.filteredTableData)")
            self.tableView.reloadData()
        })

//
//        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text)
//        let array = (searchResultsCity as NSArray).filteredArrayUsingPredicate(searchPredicate)
//        filteredTableData = array as! [CityInfo]


    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = self.filteredTableData[indexPath.row]
        var theCityID = String()
        var theCityName = String()
        var theCityLat = Double()
        var theCityLong = Double()
    
        if let cityID = selectedItem.cityID{
            theCityID = cityID
        }
        if let cityName = selectedItem.name{
             cityName
            var myArray = cityName.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: ",-"))
          
            var theCity = myArray[0]
           theCityName  = theCity
        }

        if let citylat = selectedItem.lat{
            theCityLat = citylat
        }

        if let cityLong = selectedItem.long{
            theCityLong = cityLong
        }
       let newCityNumber = numOfCity + 1

       city.createCity(theCityName, cityLat: theCityLat, cityLong: theCityLong, cityAtIndex: newCityNumber, isCurrentLocation: false)


        delegate?.cityPicked(theCityLat, long: theCityLong, name: theCityName)

       self.navigationController!.popViewControllerAnimated(true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


}
