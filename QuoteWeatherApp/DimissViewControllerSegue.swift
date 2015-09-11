//
//  DimissViewControllerSegue.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 9/9/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit

class DimissViewControllerSegue: UIStoryboardSegue {


   override func  perform() {
     let theViewController:UIViewController = self.sourceViewController as! UIViewController
    theViewController.dismissViewControllerAnimated(true, completion: {});
    }


}

